Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 13063800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 06:39:16 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id q2so95049wrg.5
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 03:39:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j21si3823845wmh.146.2018.01.23.03.39.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 03:39:14 -0800 (PST)
Date: Tue, 23 Jan 2018 12:39:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180123113912.GH1526@dhcp22.suse.cz>
References: <20180118170006.GG6584@dhcp22.suse.cz>
 <20180118171355.GH6584@dhcp22.suse.cz>
 <87k1wfgcmb.fsf@anholt.net>
 <20180119082046.GL6584@dhcp22.suse.cz>
 <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com>
 <20180119104058.GU6584@dhcp22.suse.cz>
 <d4fe7e59-da2d-11a5-73e2-55f2f27cdfd8@amd.com>
 <20180119121351.GW6584@dhcp22.suse.cz>
 <20180119122005.GX6584@dhcp22.suse.cz>
 <7c7b0616-97ba-01e7-0053-bf224ca5b5f2@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7c7b0616-97ba-01e7-0053-bf224ca5b5f2@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Cc: Eric Anholt <eric@anholt.net>, Andrey Grodzovsky <andrey.grodzovsky@amd.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org

On Fri 19-01-18 17:54:36, Christian Konig wrote:
> Am 19.01.2018 um 13:20 schrieb Michal Hocko:
> > On Fri 19-01-18 13:13:51, Michal Hocko wrote:
> > > On Fri 19-01-18 12:37:51, Christian Konig wrote:
> > > [...]
> > > > The per file descriptor badness is/was just the much easier approach to
> > > > solve the issue, because the drivers already knew which client is currently
> > > > using which buffer objects.
> > > > 
> > > > I of course agree that file descriptors can be shared between processes and
> > > > are by themselves not killable. But at least for our graphics driven use
> > > > case I don't see much of a problem killing all processes when a file
> > > > descriptor is used by more than one at the same time.
> > > Ohh, I absolutely see why you have chosen this way for your particular
> > > usecase. I am just arguing that this would rather be more generic to be
> > > merged. If there is absolutely no other way around we can consider it
> > > but right now I do not see that all other options have been considered
> > > properly. Especially when the fd based approach is basically wrong for
> > > almost anybody else.
> > And more importantly. Iterating over _all_ fd which is what is your
> > approach is based on AFAIU is not acceptable for the OOM path. Even
> > though oom_badness is not a hot path we do not really want it to take a
> > lot of time either. Even the current iteration over all processes is
> > quite time consuming. Now you want to add the number of opened files and
> > that might be quite many per process.
> 
> Mhm, crap that is a really good argument.
> 
> How about adding a linked list of callbacks to check for the OOM killer to
> check for each process?
> 
> This way we can avoid finding the process where we need to account things on
> when memory is allocated and still allow the OOM killer to only check the
> specific callbacks it needs to determine the score of a process?

I might be oversimplifying but there really have to be a boundary when
you have the target user context, no? Then do the accounting when you
get data to the user.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
