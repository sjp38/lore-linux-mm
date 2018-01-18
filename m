Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F06396B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 12:13:58 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a6so14556134wrh.10
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:13:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e25si4168942wmh.216.2018.01.18.09.13.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 09:13:57 -0800 (PST)
Date: Thu, 18 Jan 2018 18:13:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180118171355.GH6584@dhcp22.suse.cz>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180118170006.GG6584@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, Christian.Koenig@amd.com

On Thu 18-01-18 18:00:06, Michal Hocko wrote:
> On Thu 18-01-18 11:47:48, Andrey Grodzovsky wrote:
> > Hi, this series is a revised version of an RFC sent by Christian Konig
> > a few years ago. The original RFC can be found at 
> > https://lists.freedesktop.org/archives/dri-devel/2015-September/089778.html
> > 
> > This is the same idea and I've just adressed his concern from the original RFC 
> > and switched to a callback into file_ops instead of a new member in struct file.
> 
> Please add the full description to the cover letter and do not make
> people hunt links.
> 
> Here is the origin cover letter text
> : I'm currently working on the issue that when device drivers allocate memory on
> : behalf of an application the OOM killer usually doesn't knew about that unless
> : the application also get this memory mapped into their address space.
> : 
> : This is especially annoying for graphics drivers where a lot of the VRAM
> : usually isn't CPU accessible and so doesn't make sense to map into the
> : address space of the process using it.
> : 
> : The problem now is that when an application starts to use a lot of VRAM those
> : buffers objects sooner or later get swapped out to system memory, but when we
> : now run into an out of memory situation the OOM killer obviously doesn't knew
> : anything about that memory and so usually kills the wrong process.

OK, but how do you attribute that memory to a particular OOM killable
entity? And how do you actually enforce that those resources get freed
on the oom killer action?

> : The following set of patches tries to address this problem by introducing a per
> : file OOM badness score, which device drivers can use to give the OOM killer a
> : hint how many resources are bound to a file descriptor so that it can make
> : better decisions which process to kill.

But files are not killable, they can be shared... In other words this
doesn't help the oom killer to make an educated guess at all.

> : 
> : So question at every one: What do you think about this approach?

I thing is just just wrong semantically. Non-reclaimable memory is a
pain, especially when there is way too much of it. If you can free that
memory somehow then you can hook into slab shrinker API and react on the
memory pressure. If you can account such a memory to a particular
process and make sure that the consumption is bound by the process life
time then we can think of an accounting that oom_badness can consider
when selecting a victim.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
