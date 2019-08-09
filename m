Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54EE2C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 10:50:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B38C2086D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 10:50:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B38C2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F8D46B0005; Fri,  9 Aug 2019 06:50:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A8296B0006; Fri,  9 Aug 2019 06:50:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570736B0007; Fri,  9 Aug 2019 06:50:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD416B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 06:50:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so60072167edc.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 03:50:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=few8kGRrgEoloLDmaB6JT6zg2ov0KNpIUNzXgqTu95Q=;
        b=l5Mhcmd/If7mxAMGyf2A/3mz8DUmQV20a72MBglgFyAYGnLWTHBLfCS7DMF5JA1ryV
         wX/pG2mD+0MjpKStZx541riVMPnMZ3jVZJHEwa3ilJ7lDX/wLBAl0iFu2RnI8RmBO/At
         9ghLQF6rNU8NEMZIXq1+NcQ36+tRVDIfdCufPO2/rCk7hT7i45zTVond8O8w1DtSKBLX
         oRBqzZL6L7azBP9wcIoDPxl7eLt2gST+aWJI28HUpIB6z7Y5A24CzihI7bvjhIp9H+6M
         utdi991EW9xEzwU+6EPvKk5RHTSzD01UVa0Feq+96tLCGcEAnPW6S8YV8AsOuwjJIWI4
         ouow==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX2av4Q5PKa59lUxTz/vKINcyMs21jH/l8a7zMBQ59SXhq8Ys0F
	jMVctO87Zdk3y3ocvN3MVR9HiZ8AI71gQOaSFRS52LcLbZZOBWfvu/OxmE21Lr8NjBCSaoLJQA4
	0lFDfFmtpEmTYnjpIinXBbrj0uH+62zPFP1UvGaBhIV8kebkTdMZMFSGaNcS+Vow=
X-Received: by 2002:a50:b13b:: with SMTP id k56mr21682787edd.192.1565347823574;
        Fri, 09 Aug 2019 03:50:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9Q0Tn/5rjT2wVTFq/4GlsDXNoWo16oGWtfgtl4n408lgMlGy2eNPUXNxhkECXczdvu8im
X-Received: by 2002:a50:b13b:: with SMTP id k56mr21682724edd.192.1565347822651;
        Fri, 09 Aug 2019 03:50:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565347822; cv=none;
        d=google.com; s=arc-20160816;
        b=Xp8LyNuTfXohLOZ6qYikvMjdOA7ANbs8KHAI+UH7EfqHJo+U2fWfz5p0AKYcy4ygi1
         +jKy3L4RHLebjkG7cVH/3OXdMCB2lv3eJwwxTOscyTB89c7ChYBhO9IUQldLWy0gCLDD
         perf391DLJwP30A2daQFsjI0omyPjlt/AimEHne7nw9v/3aAzYDgGX43B/ODNgAxUstF
         BnwziYxgcFFFayzUhrB7KUKKRBA3rAhK1HwRnEf6WlLSngsu9N+Rr25RfdWC07pY1imS
         PElyX5UozjcSEIfoO58vTgDsdLZi/9RSUVdFYsDsgs8O5WhrOw474wg2yMZr7tX63qm+
         88Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=few8kGRrgEoloLDmaB6JT6zg2ov0KNpIUNzXgqTu95Q=;
        b=uoXSTFIOiwSXf0YiDOdq+sia7VZl0u+pCQiwpJ0nXREsTVvE1lG+h9xVAWzpsP2ksJ
         fMlMSZ4hn0mSvMp4JIA7cTupmA02LtYCIhnKLHa90wZuSWtY0H3uqoXiXyjLy6f9wySl
         569xRRUuLxYJDXfpJI7lA+wRo/DpkenZceazOzVM+h9MCDc86kUNXUzAcDx3lTaGk9cg
         5VD79nGhk+JLtjNaRSWapjvSKEZlvJ0W0U6qLvgVBykexM2L8VLJWN9K+z3IRksCxPoB
         uPCT7HHjInjYxWJDMU4y4imgOpvXYzhElDLqKuHcRAhMXuTvoeSDGEmUHziZdb4AJ3MC
         aUCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k15si32002278ejk.183.2019.08.09.03.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 03:50:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D802AB071;
	Fri,  9 Aug 2019 10:50:21 +0000 (UTC)
Date: Fri, 9 Aug 2019 12:50:16 +0200
From: Michal Hocko <mhocko@kernel.org>
To: ndrw <ndrw.xf@redhazel.co.uk>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190809105016.GP18351@dhcp22.suse.cz>
References: <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
 <20190808114826.GC18351@dhcp22.suse.cz>
 <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
 <20190808163228.GE18351@dhcp22.suse.cz>
 <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
 <20190808185925.GH18351@dhcp22.suse.cz>
 <08e5d007-a41a-e322-5631-b89978b9cc20@redhazel.co.uk>
 <20190809085748.GN18351@dhcp22.suse.cz>
 <cdb392ee-e192-c136-41cb-48d9e4e4bf47@redhazel.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cdb392ee-e192-c136-41cb-48d9e4e4bf47@redhazel.co.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 11:09:33, ndrw wrote:
> On 09/08/2019 09:57, Michal Hocko wrote:
> > We already do have a reserve (min_free_kbytes). That gives kswapd some
> > room to perform reclaim in the background without obvious latencies to
> > allocating tasks (well CPU still be used so there is still some effect).
> 
> I tried this option in the past. Unfortunately, I didn't prevent freezes. My
> understanding is this option reserves some amount of memory to not be

to not be used by normal allocations. It defines reclaim watermarks and
that influences when the background and direct reclaim start to act.

> swapped out but does not prevent the kernel from evicting all pages from
> cache when more memory is needed.

It doesn't have any say on the actual decision on what to reclaim.

> > Kswapd tries to keep a balance and free memory low but still with some
> > room to satisfy an immediate memory demand. Once kswapd doesn't catch up
> > with the memory demand we dive into the direct reclaim and that is where
> > people usually see latencies coming from.
> 
> Reclaiming memory is fine, of course, but not all the way to 0 caches. No
> caches means all executable pages, ro pages (e.g. fonts) are evicted from
> memory and have to be constantly reloaded on every user action. All this
> while competing with tasks that are using up all memory. This happens with
> of without swap, although swap does spread this issue in time a bit.

We try to protect low amount of cache. Have a look at get_scan_count
function. But the exact amount of the cache to be protected is really
hard to know wihtout a crystal ball or understanding of the workload.
The kernel doesn't have neither of the two.

> > The main problem here is that it is hard to tell from a single
> > allocation latency that we have a bigger problem. As already said, the
> > usual trashing scenario doesn't show problem during the reclaim because
> > pages can be freed up very efficiently. The problem is that they are
> > refaulted very quickly so we are effectively rotating working set like
> > crazy. Compare that to a normal used-once streaming IO workload which is
> > generating a lot of page cache that can be recycled in a similar pace
> > but a working set doesn't get freed. Free memory figures will look very
> > similar in both cases.
> 
> Thank you for the explanation. It is indeed a difficult problem - some
> cached pages (streaming IO) will likely not be needed again and should be
> discarded asap, other (like mmapped executable/ro pages of UI utilities)
> will cause thrashing when evicted under high memory pressure. Another aspect
> is that PSI is probably not the best measure of detecting imminent
> thrashing. However, if it can at least detect a freeze that has already
> occurred and force the OOM killer that is still a lot better than a dead
> system, which is the current user experience.

We have been thinking about this problem for a long time and couldn't
come up with anything much better than we have now. PSI is the most recent
improvement in that area. If you have better ideas then patches are
always welcome.

> > Good that earlyoom works for you.
> 
> I am giving it as an example of a heuristic that seems to work very well for
> me. Something to look into. And yes, I wouldn't mind having such mechanism
> built into the kernel.
> 
> >   All I am saying is that this is not
> > generally applicable heuristic because we do care about a larger variety
> > of workloads. I should probably emphasise that the OOM killer is there
> > as a _last resort_ hand break when something goes terribly wrong. It
> > operates at times when any user intervention would be really hard
> > because there is a lack of resources to be actionable.
> 
> It is indeed a last resort solution - without it the system is unusable.
> Still, accuracy matters because killing a wrong task does not fix the
> problem (a task hogging memory is still running) and may break the system
> anyway if something important is killed instead.

That is a completely orthogonal problem, I am afraid. So far we have
been discussing _when_ to trigger OOM killer. This is _who_ to kill. I
haven't heard any recent examples that the victim selection would be way
off and killing something obviously incorrect.

> [...]
> 
> > This is a useful feedback! What was your workload? Which kernel version?
> 
> I tested it by running a python script that processes a large amount of data
> in memory (needs around 15GB of RAM). I normally run 2 instances of that
> script in parallel but for testing I started 4 of them. I sometimes
> experience the same issue when using multiple regular memory intensive
> desktop applications in a manner described in the first post but that's
> harder to reproduce because of the user input needed.

Something that other people can play with to reproduce the issue would
be more than welcome.

-- 
Michal Hocko
SUSE Labs

