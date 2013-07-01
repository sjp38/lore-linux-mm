Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 29D1E6B0033
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 14:45:28 -0400 (EDT)
Date: Mon, 1 Jul 2013 14:45:03 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: PROBLEM: Processes writing large files in memory-limited LXC
 container are killed by OOM
Message-ID: <20130701184503.GG17812@cmpxchg.org>
References: <CAMcjixYa-mjo5TrxmtBkr0MOf+8r_iSeW5MF4c8nJKdp5m+RPA@mail.gmail.com>
 <20130701180101.GA5460@ac100>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130701180101.GA5460@ac100>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: Aaron Staley <aaron@picloud.com>, containers@lists.linux-foundation.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 01, 2013 at 01:01:01PM -0500, Serge Hallyn wrote:
> Quoting Aaron Staley (aaron@picloud.com):
> > This is better explained here:
> > http://serverfault.com/questions/516074/why-are-applications-in-a-memory-limited-lxc-container-writing-large-files-to-di
> > (The
> > highest-voted answer believes this to be a kernel bug.)
> 
> Hi,
> 
> in irc it has been suggested that indeed the kernel should be slowing
> down new page creates while waiting for old page cache entries to be
> written out to disk, rather than ooming.
> 
> With a 3.0.27-1-ac100 kernel, doing dd if=/dev/zero of=xxx bs=1M
> count=100 is immediately killed.  In contrast, doing the same from a
> 3.0.8 kernel did the right thing for me.  But I did reproduce your
> experiment below on ec2 with the same result.
>
> So, cc:ing linux-mm in the hopes someone can tell us whether this
> is expected behavior, known mis-behavior, or an unknown bug.

It's a known issue that was fixed/improved in e62e384 'memcg: prevent
OOM with too many dirty pages', included in 3.6+.

> > Summary: I have set up a system where I am using LXC to create multiple
> > virtualized containers on my system with limited resources. Unfortunately, I'm
> > running into a troublesome scenario where the OOM killer is hard killing
> > processes in my LXC container when I write a file with size exceeding the
> > memory limitation (set to 300MB). There appears to be some issue with the
> > file buffering respecting the containers memory limit.
> > 
> > 
> > Reproducing:
> > 
> > /done on a c1.xlarge instance running on Amazon EC2
> > 
> > Create 6 empty lxc containers (in my case I did lxc-create -n testcon -t
> > ubuntu -- -r precise)
> > 
> > Modify the configuration of each container to set lxc.cgroup.memory.
> > limit_in_bytes = 300M
> > 
> > Within each container run:
> > dd if=/dev/zero of=test2 bs=100k count=5010
> > parallel
> > 
> > This will with high probability activate the OOM (as seen in demsg); often
> > the dd processes themselves will be killed.
> > 
> > This has been verified to have problems on:
> > Linux 3.8.0-25-generic #37-Ubuntu SMP and Linux ip-10-8-139-98
> > 3.2.0-29-virtual #46-Ubuntu SMP Fri Jul 27 17:23:50 UTC 2012 x86_64 x86_64
> > x86_64 GNU/Linux
> > 
> > Please let me know your thoughts.
> > 
> > Regards,
> > Aaron Staley
> > _______________________________________________
> > Containers mailing list
> > Containers@lists.linux-foundation.org
> > https://lists.linuxfoundation.org/mailman/listinfo/containers
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
