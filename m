Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5FBA96B0092
	for <linux-mm@kvack.org>; Sat,  3 Mar 2012 09:33:01 -0500 (EST)
Date: Sat, 3 Mar 2012 22:27:45 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-ID: <20120303142745.GA17789@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144747.198713792@intel.com>
 <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
 <20120301123640.GA30369@localhost>
 <20120301163837.GA13104@quack.suse.cz>
 <20120302044858.GA14802@localhost>
 <20120302095910.GB1744@quack.suse.cz>
 <20120302103951.GA13378@localhost>
 <20120302115700.7d970497.akpm@linux-foundation.org>
 <20120303135558.GA9869@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120303135558.GA9869@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <Artem.Bityutskiy@linux.intel.com>, Adrian Hunter <adrian.hunter@intel.com>

[correct email addresses for Artem and Adrian]

On Sat, Mar 03, 2012 at 09:55:58PM +0800, Fengguang Wu wrote:
> On Fri, Mar 02, 2012 at 11:57:00AM -0800, Andrew Morton wrote:
> > On Fri, 2 Mar 2012 18:39:51 +0800
> > Fengguang Wu <fengguang.wu@intel.com> wrote:
> > 
> > > > And I agree it's unlikely but given enough time and people, I
> > > > believe someone finds a way to (inadvertedly) trigger this.
> > > 
> > > Right. The pageout works could add lots more iput() to the flusher
> > > and turn some hidden statistical impossible bugs into real ones.
> > > 
> > > Fortunately the "flusher deadlocks itself" case is easy to detect and
> > > prevent as illustrated in another email.
> > 
> > It would be a heck of a lot safer and saner to avoid the iput().  We
> > know how to do this, so why not do it?
> 
> My concern about the page lock is, it costs more code and sounds like
> hacking around something. It seems we (including me) have been trying
> to shun away from the iput() problem. Since it's unlikely we are to
> get rid of the already existing iput() calls from the flusher context,
> why not face the problem, sort it out and use it with confident in new
> code?
> 
> Let me try it now. The only scheme iput() can deadlock the flusher is
> for the iput() path to come back to queue some work and wait for it.
> Here are the exhaust list of the queue+wait paths:
> 
> writeback_inodes_sb_nr_if_idle
>   ext4_nonda_switch
>     ext4_page_mkwrite                   # from page fault
>     ext4_da_write_begin                 # from user writes
> 
> writeback_inodes_sb_nr
>   quotactl syscall                      # from syscall
>   __sync_filesystem                     # from sync/umount
>   shrink_liability                      # ubifs
>     make_free_space
>       ubifs_budget_space                # from all over ubifs:
> 
>    2    274  /c/linux/fs/ubifs/dir.c <<ubifs_create>>
>    3    531  /c/linux/fs/ubifs/dir.c <<ubifs_link>>
>    4    586  /c/linux/fs/ubifs/dir.c <<ubifs_unlink>>
>    5    675  /c/linux/fs/ubifs/dir.c <<ubifs_rmdir>>
>    6    731  /c/linux/fs/ubifs/dir.c <<ubifs_mkdir>>
>    7    803  /c/linux/fs/ubifs/dir.c <<ubifs_mknod>>
>    8    871  /c/linux/fs/ubifs/dir.c <<ubifs_symlink>>
>    9   1006  /c/linux/fs/ubifs/dir.c <<ubifs_rename>>
>   10   1009  /c/linux/fs/ubifs/dir.c <<ubifs_rename>>
>   11    246  /c/linux/fs/ubifs/file.c <<write_begin_slow>>
>   12    388  /c/linux/fs/ubifs/file.c <<allocate_budget>>
>   13   1125  /c/linux/fs/ubifs/file.c <<do_truncation>>   <===== deadlockable
>   14   1217  /c/linux/fs/ubifs/file.c <<do_setattr>>
>   15   1381  /c/linux/fs/ubifs/file.c <<update_mctime>>
>   16   1486  /c/linux/fs/ubifs/file.c <<ubifs_vm_page_mkwrite>>
>   17    110  /c/linux/fs/ubifs/ioctl.c <<setflags>>
>   19    122  /c/linux/fs/ubifs/xattr.c <<create_xattr>>
>   20    201  /c/linux/fs/ubifs/xattr.c <<change_xattr>>
>   21    494  /c/linux/fs/ubifs/xattr.c <<remove_xattr>>
> 
> It seems they are all safe except for ubifs. ubifs may actually
> deadlock from the above do_truncation() caller. However it should be

Sorry that do_truncation() is actually called from ubifs_setattr()
which is not related to iput().

Are there other possibilities for iput() to call into the above list
of ubifs functions, then start writeback work and wait for it which
will deadlock the flusher? ubifs_unlink() and perhaps remove_xattr()?

> fixable because the ubifs call for writeback_inodes_sb_nr() sounds
> very brute force writeback and wait and there may well be better way
> out.
> 
> CCing ubifs developers for possible thoughts..
> 
> Thanks,
> Fengguang
> 
> PS. I'll be on travel in the following week and won't have much time
> for replying emails. Sorry about that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
