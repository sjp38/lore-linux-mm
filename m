Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4471DC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:47:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0487122CED
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:47:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0487122CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90FE18E0002; Fri, 26 Jul 2019 09:47:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BFC16B0007; Fri, 26 Jul 2019 09:47:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D5B78E0002; Fri, 26 Jul 2019 09:47:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5F46B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:47:23 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t124so45285466qkh.3
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:47:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=aREd7oX/KjjR1y+/DoK7i/ri4F4zE0JK5o/p5Emjkas=;
        b=SC8bsHKa4DWsBL0OvVE5iyscZZ52RyE7IeZiajhMRRoki1QslSn7Utni+xZArHz4oB
         HOmBcg8U9nhyb6q0HfEtJsg0vVU5F8pMRZ61l41vVTiSYu7hd8weWoGee+gWm0JbWABw
         +3DoHLKkxxQH3sIQhDqy0ykjNbRYbldLasm40yVqv08zXHdkCTk78RFg9uCLSePSopjG
         EmTn+GfMf32dKXnz79r4nbPeurOUIP4Qq7Eoahd3/Zjtw3RFxJPdJglkD34i74zb6271
         26toifPbEPML9q9wJ4HmLHUdX3uobFtwst2emw3L32bMjGK+dAY3kiX86zE/q9F5ZaUp
         CcrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXINIGekZLWoRe6mSHp52RzEoNhVmINiwvxkd86/v9iRxoe74rO
	3vVJLIBTsS6UgiUUCIpalQ3WbZFr265iDOUcYOsejxNOGUUhhzun5ZBAYiWCt3EMoQOiSVNEccf
	KWnHlmrS1W7Sq96g8YXMJAKOxYx0xJ7VeoOdrgO3x/SpRynnqQqRSqW0T2veomLAHJQ==
X-Received: by 2002:a05:620a:1456:: with SMTP id i22mr61550402qkl.170.1564148843121;
        Fri, 26 Jul 2019 06:47:23 -0700 (PDT)
X-Received: by 2002:a05:620a:1456:: with SMTP id i22mr61550362qkl.170.1564148842494;
        Fri, 26 Jul 2019 06:47:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148842; cv=none;
        d=google.com; s=arc-20160816;
        b=d2kS4orJKAU3K9AFDBgylXZEql+bEgCf67XqR7OY4+Elafo+8WYDGxoVNTNXWN39wd
         kUeqMNwJrybITWE6ysq47JFQK/xnjX7LMYIemKp/qKHT06hjGMyzwHbpaTGuX/iLumra
         8NUHNbreLnwld+SZ9hW7ZMlr8T/1Up9BuKWm6KLA/bxjeLNR9MGh0HRLWRSmdlfqWcTd
         jGtY9kxpbJhA28eIjr2R7rGuWRzdZcsAS0semPAJDjauRvbbsPuyjlzqjBTBDfASMGWq
         fwNkFVlP+XQ9D4bE+M0khdlPEf7btcN/1HVcma6YB1yh5PxFrd6OIOJej5KKPbBmhCWt
         APZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=aREd7oX/KjjR1y+/DoK7i/ri4F4zE0JK5o/p5Emjkas=;
        b=iVHTvNTseO4L5nlhmtcqQe1Hp+YEjagPt8LSN017L42w4tJdB0AT2d+A4vsmjgv6gC
         QCjKv6+BPDslPgUwB6ikunic6ZxCKvOHjVIDCMzF62DUg4P3JVXVFL8BQyaIZuJ9p5cF
         PoQQbAHh/FMLdG4uvuitaL6j4QZ2BlDkdGV1uLGQqlJURS0Jrs+0RvxRjGdiecPjHdH7
         1JgClu4imn8iaD5Wiv+79pdsY8vhSUf2TNQierMVeB2qaePdCDCpWvbhdAUqVmT5a1b9
         xMfiPfkpAIwgXZ3t4wuSwUi+Ek07182g74syCgatggCzUKinpsMk/8CAKEITws9DUWg/
         6b3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2sor38604628qvn.72.2019.07.26.06.47.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 06:47:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzVdYsizVTGT9hdpWznFaUhHBwNJSFBNQoI8apQUSuT6ROsP77q6nipE0mfzkXGrjdjl9uw3A==
X-Received: by 2002:a0c:ba0b:: with SMTP id w11mr68077058qvf.71.1564148842235;
        Fri, 26 Jul 2019 06:47:22 -0700 (PDT)
Received: from redhat.com ([212.92.104.165])
        by smtp.gmail.com with ESMTPSA id g2sm21326394qkm.31.2019.07.26.06.47.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 06:47:21 -0700 (PDT)
Date: Fri, 26 Jul 2019 09:47:12 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190726094353-mutt-send-email-mst@kernel.org>
References: <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 08:53:18PM +0800, Jason Wang wrote:
> 
> On 2019/7/26 下午8:38, Michael S. Tsirkin wrote:
> > On Fri, Jul 26, 2019 at 08:00:58PM +0800, Jason Wang wrote:
> > > On 2019/7/26 下午7:49, Michael S. Tsirkin wrote:
> > > > On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
> > > > > On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
> > > > > > > Exactly, and that's the reason actually I use synchronize_rcu() there.
> > > > > > > 
> > > > > > > So the concern is still the possible synchronize_expedited()?
> > > > > > I think synchronize_srcu_expedited.
> > > > > > 
> > > > > > synchronize_expedited sends lots of IPI and is bad for realtime VMs.
> > > > > > 
> > > > > > > Can I do this
> > > > > > > on through another series on top of the incoming V2?
> > > > > > > 
> > > > > > > Thanks
> > > > > > > 
> > > > > > The question is this: is this still a gain if we switch to the
> > > > > > more expensive srcu? If yes then we can keep the feature on,
> > > > > I think we only care about the cost on srcu_read_lock() which looks pretty
> > > > > tiny form my point of view. Which is basically a READ_ONCE() + WRITE_ONCE().
> > > > > 
> > > > > Of course I can benchmark to see the difference.
> > > > > 
> > > > > 
> > > > > > if not we'll put it off until next release and think
> > > > > > of better solutions. rcu->srcu is just a find and replace,
> > > > > > don't see why we need to defer that. can be a separate patch
> > > > > > for sure, but we need to know how well it works.
> > > > > I think I get here, let me try to do that in V2 and let's see the numbers.
> > > > > 
> > > > > Thanks
> > > 
> > > It looks to me for tree rcu, its srcu_read_lock() have a mb() which is too
> > > expensive for us.
> > I will try to ponder using vq lock in some way.
> > Maybe with trylock somehow ...
> 
> 
> Ok, let me retry if necessary (but I do remember I end up with deadlocks
> last try).
> 
> 
> > 
> > 
> > > If we just worry about the IPI,
> > With synchronize_rcu what I would worry about is that guest is stalled
> 
> 
> Can this synchronize_rcu() be triggered by guest? If yes, there are several
> other MMU notifiers that can block. Is vhost something special here?

Sorry, let me explain: guests (and tasks in general)
can trigger activity that will
make synchronize_rcu take a long time. Thus blocking
an mmu notifier until synchronize_rcu finishes
is a bad idea.

> 
> > because system is busy because of other guests.
> > With expedited it's the IPIs...
> > 
> 
> The current synchronize_rcu()  can force a expedited grace period:
> 
> void synchronize_rcu(void)
> {
>         ...
>         if (rcu_blocking_is_gp())
> return;
>         if (rcu_gp_is_expedited())
> synchronize_rcu_expedited();
> else
> wait_rcu_gp(call_rcu);
> }
> EXPORT_SYMBOL_GPL(synchronize_rcu);


An admin can force rcu to finish faster, trading
interrupts for responsiveness.

> 
> > > can we do something like in
> > > vhost_invalidate_vq_start()?
> > > 
> > >          if (map) {
> > >                  /* In order to avoid possible IPIs with
> > >                   * synchronize_rcu_expedited() we use call_rcu() +
> > >                   * completion.
> > > */
> > > init_completion(&c.completion);
> > >                  call_rcu(&c.rcu_head, vhost_finish_vq_invalidation);
> > > wait_for_completion(&c.completion);
> > >                  vhost_set_map_dirty(vq, map, index);
> > > vhost_map_unprefetch(map);
> > >          }
> > > 
> > > ?
> > Why would that be faster than synchronize_rcu?
> 
> 
> No faster but no IPI.
> 

Sorry I still don't see the point.
synchronize_rcu doesn't normally do an IPI either.


> > 
> > 
> > > > There's one other thing that bothers me, and that is that
> > > > for large rings which are not physically contiguous
> > > > we don't implement the optimization.
> > > > 
> > > > For sure, that can wait, but I think eventually we should
> > > > vmap large rings.
> > > 
> > > Yes, worth to try. But using direct map has its own advantage: it can use
> > > hugepage that vmap can't
> > > 
> > > Thanks
> > Sure, so we can do that for small rings.
> 
> 
> Yes, that's possible but should be done on top.
> 
> Thanks

Absolutely. Need to fix up the bugs first.

-- 
MST

