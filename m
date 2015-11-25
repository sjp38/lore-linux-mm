Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id A36E16B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 17:12:37 -0500 (EST)
Received: by wmvv187 with SMTP id v187so6122846wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 14:12:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q5si37409959wjq.6.2015.11.25.14.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 14:12:36 -0800 (PST)
Date: Wed, 25 Nov 2015 14:12:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, vmstat: Allow WQ concurrency to discover memory
 reclaim doesn't make any progress
Message-Id: <20151125141233.aa6dcb1a35527a363cb0776a@linux-foundation.org>
In-Reply-To: <20151125110705.GC27283@dhcp22.suse.cz>
References: <1447936253-18134-1-git-send-email-mhocko@kernel.org>
	<20151124154448.ac124e62528db313279224ef@linux-foundation.org>
	<20151125110705.GC27283@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, Cristopher Lameter <clameter@sgi.com>, Arkadiusz =?UTF-8?Q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>

On Wed, 25 Nov 2015 12:07:05 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 24-11-15 15:44:48, Andrew Morton wrote:
> [...]
> > > Even though we haven't seen bug reports in the past I would suggest
> > > backporting this to the stable trees. The issue is present since we have
> > > stopped useing congestion_wait in the retry loop because WQ concurrency
> > > is older as well as vmstat worqueue based refresh AFAICS.
> >
> > hm, I'm reluctant.  If the patch fixes something that real people are
> > really hurting from then yes.  But I suspect this is just one fly-swat
> > amongst many.
> 
> Arkadiusz was seeing reclaim issues [1] on 4.1 kernel. I didn't have
> time to look deeper in that report but vmstat counters seemed terribly
> outdated and the issue went away when this patch was used. The thing is
> that there were others in the bundle so it is not 100% clear whether the
> patch alone helped or it was just a part of the puzzle.
> 
> Anyway I think that the issue is not solely theoretical. WQ_MEM_RECLAIM
> is simply not working if the allocation path doesn't sleep currently and
> my understanding of what Tejun claims [2] is that that reimplementing WQ
> concurrency would be too intrusive and lacks sufficient justification
> because other kernel paths do sleep. This patch tries to reduce the
> sleep only to worker threads which should not cause any problems to
> regular tasks.
> 
> I am open to any other suggestions. I do not like artificial sleep as
> well but this sounds like the most practical way to go now.
> 
> [1] http://lkml.kernel.org/r/201511102313.36685.arekm@maven.pl
> [2] http://lkml.kernel.org/r/20151106001648.GA18183@mtj.duckdns.org

hmpf, OK, I stuck a cc:stable in there.  It looks like the current
changelog is sufficient to explain to Greg (and others) why we think
backporting is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
