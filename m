Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C26BA6B0003
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 01:55:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z13so1797874pfe.21
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 22:55:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f3-v6si7379134plr.453.2018.04.06.22.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 22:55:47 -0700 (PDT)
Subject: Re: WARNING in kill_block_super
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <001a114043bcfab6ab05689518f9@google.com>
	<6c95e826-4b9f-fb21-b311-830411e58480@I-love.SAKURA.ne.jp>
	<20180406080922.GH8286@dhcp22.suse.cz>
In-Reply-To: <20180406080922.GH8286@dhcp22.suse.cz>
Message-Id: <201804071455.DEE05781.LJOHMFSQVtFOOF@I-love.SAKURA.ne.jp>
Date: Sat, 7 Apr 2018 14:55:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: viro@zeniv.linux.org.uk, syzbot+5a170e19c963a2e0df79@syzkaller.appspotmail.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, dvyukov@google.com

Michal Hocko wrote:
> On Wed 04-04-18 19:53:07, Tetsuo Handa wrote:
> > Al and Michal, are you OK with this patch?
> 
> Maybe I've misunderstood, but hasn't Al explained [1] that the
> appropriate fix is in the fs code?
> 
> [1] http://lkml.kernel.org/r/20180402143415.GC30522@ZenIV.linux.org.uk

Yes. But I wonder whether it worth complicating sget() only for handling
kmalloc() failure.

----------------------------------------
static struct file_system_type fuseblk_fs_type = {
  .owner          = THIS_MODULE,
  .name           = "fuseblk",
  .mount          = fuse_mount_blk,
  .kill_sb        = fuse_kill_sb_blk,
  .fs_flags       = FS_REQUIRES_DEV | FS_HAS_SUBTYPE,
};

static struct dentry *fuse_mount_blk(struct file_system_type *fs_type, int flags, const char *dev_name, void *raw_data) {
  return mount_bdev(fs_type, flags, dev_name, raw_data, fuse_fill_super) {
    fmode_t mode = FMODE_READ | FMODE_EXCL;
    if (!(flags & MS_RDONLY)) mode |= FMODE_WRITE;
    s = sget(fs_type, test_bdev_super, set_bdev_super, flags | MS_NOSEC, bdev) {
      return sget_userns(type, test, set, flags, user_ns, data) {
        s = alloc_super(type, (flags & ~MS_SUBMOUNT), user_ns);
        err = register_shrinker(&s->s_shrink);
        if (err) {
          deactivate_locked_super(s) {
            fs->kill_sb(s) = fuse_kill_sb_blk(s) {
              kill_block_super(sb) {
                struct block_device *bdev = sb->s_bdev;
                fmode_t mode = sb->s_mode;
                WARN_ON_ONCE(!(mode & FMODE_EXCL)); // <= Unsafe because FMODE_EXCL is not yet set which will be set at
                blkdev_put(bdev, mode | FMODE_EXCL);
              }
            }
          }
          s = ERR_PTR(err);
        }
      }
    }
    /* If sget() succeeds then ... */
    s->s_mode = mode;                               // <= this location.
    error = fill_super(s, data, flags & MS_SILENT ? 1 : 0);
    if (error) {
      deactivate_locked_super(s) {
        fs->kill_sb(s) = fuse_kill_sb_blk(s) {
          kill_block_super(sb) {
            struct block_device *bdev = sb->s_bdev;
            fmode_t mode = sb->s_mode;
            WARN_ON_ONCE(!(mode & FMODE_EXCL));     // <= Safe because FMODE_EXCL already set.
            blkdev_put(bdev, mode | FMODE_EXCL);
          }
        }
      }
      goto error;
    }
    /* If sget() fails then ... */
    error = PTR_ERR(s);
    blkdev_put(bdev, mode);                         // <= Calls blkdev_put() after deactivate_locked_super() already called blkdev_put().
  }
}
----------------------------------------

mount_bdev() is not ready to call blkdev_put() from sget().
Do we want to pass "s->s_mode" to sget() which allocates "s" ?

I feel it is preposterous that a function which allocates memory for an object
requires some of fields being already initialized in order to call a destroy
function.

By splitting register_shrinker() into prepare_shrinker() which might fail and
register_shrinker_prepared() which will not fail, we can allow shrinker users
to allocate memory at object creation time. I wrote a patch which adds
__must_check to register_shrinker() and we keep that patch in linux-next.git,
but what we got is a fake change which do not implement proper error handling
(e.g.

  Commit 6c4ca1e36cdc1a0a ("bcache: check return value of register_shrinker")

        if (register_shrinker(&c->shrink))
                pr_warn("bcache: %s: could not register shrinker",
                                __func__);

). It is not trivial to undo an error at register_shrinker().
Allocating memory for the shrinker at the time memory for an object which
contains the shrinker is allocated is much easier to undo.
