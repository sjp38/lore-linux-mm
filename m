Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6567C6B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 07:17:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h17-v6so1730575edq.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 04:17:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5-v6si2309928edd.19.2018.07.04.04.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 04:17:33 -0700 (PDT)
Date: Wed, 4 Jul 2018 13:17:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180704111731.GJ22503@dhcp22.suse.cz>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com, zi.yan@cs.rutgers.edu

On Wed 04-07-18 19:01:51, Tetsuo Handa wrote:
> +Michal Hocko
> 
> On 2018/07/04 13:19, syzbot wrote:
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    d3bc0e67f852 Merge tag 'for-4.18-rc2-tag' of git://git.ker..
> > git tree:       upstream
> > console output: https://syzkaller.appspot.com/x/log.txt?x=1000077c400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=a63be0c83e84d370
> > dashboard link: https://syzkaller.appspot.com/bug?extid=5dcb560fe12aa5091c06
> > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > userspace arch: i386
> > syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=158577a2400000
> 
> Here is C reproducer made from syz reproducer. mlockall(MCL_FUTURE) is involved.
> 
> This problem is triggerable by an unprivileged user.
> Shows different result on x86_64 (crash) and x86_32 (stall).
> 
> ------------------------------------------------------------
> /* Need to compile using "-m32" option if host is 64bit. */
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <sys/mman.h>
> int uselib(const char *library);
> 
> int main(int argc, char *argv[])
> {
> 	int fd = open("file", O_WRONLY | O_CREAT, 0644);
> 	write(fd, "\x7f\x45\x4c\x46\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02"
> 	      "\x00\x06\x00\xca\x3f\x8b\xca\x00\x00\x00\x00\x38\x00\x00\x00\x00\x00"
> 	      "\x00\xf7\xff\xff\xff\xff\xff\xff\x1f\x00\x02\x00\x00\x00\x00\x00\x00"
> 	      "\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf8\x7b"
> 	      "\x66\xff\x00\x00\x05\x00\x00\x00\x76\x86\x00\x00\x00\x00\x00\x00\x00"
> 	      "\x00\x00\x00\x31\x0f\xf3\xee\xc1\xb0\x00\x0c\x08\x53\x55\xbe\x88\x47"
> 	      "\xc2\x2e\x30\xf5\x62\x82\xc6\x2c\x95\x72\x3f\x06\x8f\xe4\x2d\x27\x96"
> 	      "\xcc", 120);
> 	fchmod(fd, 0755);
> 	close(fd);
> 	mlockall(MCL_FUTURE); /* Removing this line avoids the bug. */
> 	uselib("file");
> 	return 0;
> }
> ------------------------------------------------------------
> 
> ------------------------------------------------------------
> CentOS Linux 7 (Core)
> Kernel 4.18.0-rc3 on an x86_64
> 
> localhost login: [   81.210241] emacs (9634) used greatest stack depth: 10416 bytes left
> [  140.099935] ------------[ cut here ]------------
> [  140.101904] kernel BUG at mm/gup.c:1242!

Is this 
	VM_BUG_ON(len != PAGE_ALIGN(len));
in __mm_populate? I do not really get why we should VM_BUG_ON when the
len is not page aligned to be honest. The library is probably containing
some funky setup but if we simply cannot round up to the next PAGE_SIZE
boundary then we should probably just error out and fail. This is an
area I am really familiar with so I cannot really judge.
-- 
Michal Hocko
SUSE Labs
