Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 557EA800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:36:34 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id q2so482105wrg.5
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:36:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g65si440134wrd.332.2018.01.23.07.36.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 07:36:33 -0800 (PST)
Date: Tue, 23 Jan 2018 16:36:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180123153631.GR1526@dhcp22.suse.cz>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz>
 <20180123152659.GA21817@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180123152659.GA21817@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrey Grodzovsky <andrey.grodzovsky@amd.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, Christian.Koenig@amd.com

On Tue 23-01-18 15:27:00, Roman Gushchin wrote:
> On Thu, Jan 18, 2018 at 06:00:06PM +0100, Michal Hocko wrote:
> > On Thu 18-01-18 11:47:48, Andrey Grodzovsky wrote:
> > > Hi, this series is a revised version of an RFC sent by Christian Konig
> > > a few years ago. The original RFC can be found at 
> > > https://urldefense.proofpoint.com/v2/url?u=https-3A__lists.freedesktop.org_archives_dri-2Ddevel_2015-2DSeptember_089778.html&d=DwIDAw&c=5VD0RTtNlTh3ycd41b3MUw&r=jJYgtDM7QT-W-Fz_d29HYQ&m=R-JIQjy8rqmH5qD581_VYL0Q7cpWSITKOnBCE-3LI8U&s=QZGqKpKuJ2BtioFGSy8_721owcWJ0J6c6d4jywOwN4w&
> > Here is the origin cover letter text
> > : I'm currently working on the issue that when device drivers allocate memory on
> > : behalf of an application the OOM killer usually doesn't knew about that unless
> > : the application also get this memory mapped into their address space.
> > : 
> > : This is especially annoying for graphics drivers where a lot of the VRAM
> > : usually isn't CPU accessible and so doesn't make sense to map into the
> > : address space of the process using it.
> > : 
> > : The problem now is that when an application starts to use a lot of VRAM those
> > : buffers objects sooner or later get swapped out to system memory, but when we
> > : now run into an out of memory situation the OOM killer obviously doesn't knew
> > : anything about that memory and so usually kills the wrong process.
> > : 
> > : The following set of patches tries to address this problem by introducing a per
> > : file OOM badness score, which device drivers can use to give the OOM killer a
> > : hint how many resources are bound to a file descriptor so that it can make
> > : better decisions which process to kill.
> > : 
> > : So question at every one: What do you think about this approach?
> > : 
> > : My biggest concern right now is the patches are messing with a core kernel
> > : structure (adding a field to struct file). Any better idea? I'm considering
> > : to put a callback into file_ops instead.
> 
> Hello!
> 
> I wonder if groupoom (aka cgroup-aware OOM killer) can work for you?

I do not think so. The problem is that the allocating context is not
identical with the end consumer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
