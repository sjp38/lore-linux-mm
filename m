Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA546B025F
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 03:20:53 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 199so1172719pfy.18
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 00:20:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si8696350pfk.379.2018.01.19.00.20.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 00:20:51 -0800 (PST)
Date: Fri, 19 Jan 2018 09:20:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180119082046.GL6584@dhcp22.suse.cz>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz>
 <20180118171355.GH6584@dhcp22.suse.cz>
 <87k1wfgcmb.fsf@anholt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87k1wfgcmb.fsf@anholt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Anholt <eric@anholt.net>
Cc: Andrey Grodzovsky <andrey.grodzovsky@amd.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, Christian.Koenig@amd.com

On Thu 18-01-18 12:01:32, Eric Anholt wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Thu 18-01-18 18:00:06, Michal Hocko wrote:
> >> On Thu 18-01-18 11:47:48, Andrey Grodzovsky wrote:
> >> > Hi, this series is a revised version of an RFC sent by Christian Konig
> >> > a few years ago. The original RFC can be found at 
> >> > https://lists.freedesktop.org/archives/dri-devel/2015-September/089778.html
> >> > 
> >> > This is the same idea and I've just adressed his concern from the original RFC 
> >> > and switched to a callback into file_ops instead of a new member in struct file.
> >> 
> >> Please add the full description to the cover letter and do not make
> >> people hunt links.
> >> 
> >> Here is the origin cover letter text
> >> : I'm currently working on the issue that when device drivers allocate memory on
> >> : behalf of an application the OOM killer usually doesn't knew about that unless
> >> : the application also get this memory mapped into their address space.
> >> : 
> >> : This is especially annoying for graphics drivers where a lot of the VRAM
> >> : usually isn't CPU accessible and so doesn't make sense to map into the
> >> : address space of the process using it.
> >> : 
> >> : The problem now is that when an application starts to use a lot of VRAM those
> >> : buffers objects sooner or later get swapped out to system memory, but when we
> >> : now run into an out of memory situation the OOM killer obviously doesn't knew
> >> : anything about that memory and so usually kills the wrong process.
> >
> > OK, but how do you attribute that memory to a particular OOM killable
> > entity? And how do you actually enforce that those resources get freed
> > on the oom killer action?
> >
> >> : The following set of patches tries to address this problem by introducing a per
> >> : file OOM badness score, which device drivers can use to give the OOM killer a
> >> : hint how many resources are bound to a file descriptor so that it can make
> >> : better decisions which process to kill.
> >
> > But files are not killable, they can be shared... In other words this
> > doesn't help the oom killer to make an educated guess at all.
> 
> Maybe some more context would help the discussion?
> 
> The struct file in patch 3 is the DRM fd.  That's effectively "my
> process's interface to talking to the GPU" not "a single GPU resource".
> Once that file is closed, all of the process's private, idle GPU buffers
> will be immediately freed (this will be most of their allocations), and
> some will be freed once the GPU completes some work (this will be most
> of the rest of their allocations).
> 
> Some GEM BOs won't be freed just by closing the fd, if they've been
> shared between processes.  Those are usually about 8-24MB total in a
> process, rather than the GBs that modern apps use (or that our testcases
> like to allocate and thus trigger oomkilling of the test harness instead
> of the offending testcase...)
> 
> Even if we just had the private+idle buffers being accounted in OOM
> badness, that would be a huge step forward in system reliability.

OK, in that case I would propose a different approach. We already
have rss_stat. So why do not we simply add a new counter there
MM_KERNELPAGES and consider those in oom_badness? The rule would be
that such a memory is bound to the process life time. I guess we will
find more users for this later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
