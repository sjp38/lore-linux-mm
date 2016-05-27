Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9F56B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 02:45:15 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id j12so19193703lbo.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 23:45:15 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ez7si23790217wjd.197.2016.05.26.23.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 23:45:12 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n129so11374453wmn.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 23:45:12 -0700 (PDT)
Date: Fri, 27 May 2016 08:45:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are no
 external tasks sharing mm
Message-ID: <20160527064510.GA27686@dhcp22.suse.cz>
References: <1464266415-15558-2-git-send-email-mhocko@kernel.org>
 <201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
 <20160526145930.GF23675@dhcp22.suse.cz>
 <201605270025.IAC48454.QSHOOMFOLtFJFV@I-love.SAKURA.ne.jp>
 <20160526153532.GG23675@dhcp22.suse.cz>
 <201605270114.IEI48969.MFFtFOJLQOOHSV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605270114.IEI48969.MFFtFOJLQOOHSV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 01:14:35, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 27-05-16 00:25:23, Tetsuo Handa wrote:
> > > I think that remembering whether this mm might be shared between
> > > multiple thread groups at clone() time (i.e. whether
> > > clone(CLONE_VM without CLONE_SIGHAND) was ever requested on this mm)
> > > is safe (given that that thread already got SIGKILL or is exiting).
> > 
> > I was already playing with that idea but I didn't want to add anything
> > to the fork path which is really hot. This patch is not really needed
> > for the rest. It just felt like a nice optimization. I do not think it
> > is worth deeper changes in the fast paths.
> 
> "[PATCH 6/6] mm, oom: fortify task_will_free_mem" depends on [PATCH 1/6].
> You will need to update [PATCH 6/6].
> 
> It seems to me that [PATCH 6/6] resembles
> http://lkml.kernel.org/r/201605250005.GHH26082.JOtQOSLMFFOFVH@I-love.SAKURA.ne.jp .
> I think we will be happy if we can speed up mm_is_reapable() test using
> "whether this mm might be shared between multiple thread groups" flag.
> I don't think updating such flag at clone() is too heavy operation to add.

It is still an operation which is not needed for 99% of situations. So
if we do not need it for correctness then I do not think this is worth
bothering.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
