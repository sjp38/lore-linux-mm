Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 395C9C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:49:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D449722CD8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:49:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D449722CD8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BA986B0006; Fri, 26 Jul 2019 09:49:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1447B6B0007; Fri, 26 Jul 2019 09:49:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F27E68E0003; Fri, 26 Jul 2019 09:49:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD6536B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:49:49 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n190so45238000qkd.5
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:49:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=Arc7jiA/gNfqVVW7QNfgaMfkpV6mHYMiv3nUsNQh21Q=;
        b=CyRiIy/YnVu9t/ONbE4ynLBIA3HCfCjEIUQEQbO3Ft1czEsjT7Vf4BhZujaoB6946/
         LZyPdI3YMJfm4RL3aNLK1ItiZRbl+cCbCesddNRgDxYPQMEAiG+Ks4y9NLO0MnG4VjZE
         0enS4EcL5pysSQE14BZ5UkCK9yk2wUCbR4wdsviqL3ZW9AIg8NcykDH2wHj6rDuoz65B
         htZyW9UhprDJNC/hGjOmZYDlyfZh26YaFRJB5Frs+JR/H82gWxrvav4X6xC3cxirtai1
         ylz3qvDt69vp1ZaVxwrD5CLdJvgAtuSWe+UcLG8wmTuyVc7ojVyM6o4sfXEwXKjSg02s
         c5Ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXEWiGV3BiUman2xSIfwd4+2GKXtKpxcrwQF5s8BHqIH3JlhZqk
	mr1VRbRISQsub6iks8lI30+y0+MOotf6BfRrvw5iyw7Dic6q0wiK9czs/4SLdZ/LuIaM5dyG012
	Yqyc5fcZ8gAIr8esb/T8TovGjsEzvkGY43slSBSIthEjCOWs6ehqCCzw4SjYxFFHsqQ==
X-Received: by 2002:a37:660b:: with SMTP id a11mr60772980qkc.342.1564148989620;
        Fri, 26 Jul 2019 06:49:49 -0700 (PDT)
X-Received: by 2002:a37:660b:: with SMTP id a11mr60772946qkc.342.1564148989142;
        Fri, 26 Jul 2019 06:49:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148989; cv=none;
        d=google.com; s=arc-20160816;
        b=0SPmRziSilNv10XSvD2D3iPSb2u98VTqQGixgaCf70ntk3Ve/hQG7VqUm7EQZa+xzV
         rIUBE5BfvcUeVF/YB9VSf81y0bvi5auaHDYE1jq6TLta3WIiC36596CHHN5dqjc5WNx9
         F3qM/dMiocPhjt6KCBaoe8RLAQXjBhiq4E2/AGjaKp/V1ZzP2Pe+YpNwsZHfRkC6AIXd
         LtG24mHA1DDcK2eLIAfoLEuPzfADVoDIWFoipmB4H9tZnEII+Mo3gS+gcp2gQqVzVax+
         5Jrs6SytifWQKIcu76vt5joYua/4xCsxeI9Ejoll3NXjPGPE4H/uiOfs6O2+Ayxz/CzU
         ObkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=Arc7jiA/gNfqVVW7QNfgaMfkpV6mHYMiv3nUsNQh21Q=;
        b=ZowPXQI2eK0lNmUPZ15tAyRanI/orOEzUt6V72fUiPF5nnKDvigMHvTtQV7f9VU/r6
         CLFkDKvL+mZHejeJVL/ivxVPTEpH34Vq6hgV9ZUMoDZUS5Kstk71QiFWOpgZrGOmCp9i
         I/F9LWVWVZ5ozPTwIKK2UDhiXnr+Wug353+14vpVBNDM2qBDKCLJdwW7VF10yYvc0/hb
         zG9pIQQzGG3Fo7a4+ZS4R4iVcXUDBcEbGe4xQZRyIK/C4vHa+VRv8OsAwGV3SLX3y/LY
         svGZyE0cBXBwQAuE0V9+6puDtt8Z7wk0aAKmFgbHOVaCZeydifHeYiP3cGghc/I5ibjb
         zXng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n54sor45663079qvc.31.2019.07.26.06.49.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 06:49:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwJQHLCc1j1lFY5aAZTn5kwYloU8xFZNwjN11XBjJ1dY1OXNTBegRGc33x5aUh2wiZJ7uMG3w==
X-Received: by 2002:a0c:9233:: with SMTP id a48mr67054287qva.66.1564148988892;
        Fri, 26 Jul 2019 06:49:48 -0700 (PDT)
Received: from redhat.com ([212.92.104.165])
        by smtp.gmail.com with ESMTPSA id w19sm20959381qkj.66.2019.07.26.06.49.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 06:49:48 -0700 (PDT)
Date: Fri, 26 Jul 2019 09:49:39 -0400
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
Message-ID: <20190726094756-mutt-send-email-mst@kernel.org>
References: <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 09:36:18PM +0800, Jason Wang wrote:
> 
> On 2019/7/26 下午8:53, Jason Wang wrote:
> > 
> > On 2019/7/26 下午8:38, Michael S. Tsirkin wrote:
> > > On Fri, Jul 26, 2019 at 08:00:58PM +0800, Jason Wang wrote:
> > > > On 2019/7/26 下午7:49, Michael S. Tsirkin wrote:
> > > > > On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
> > > > > > On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
> > > > > > > > Exactly, and that's the reason actually I use
> > > > > > > > synchronize_rcu() there.
> > > > > > > > 
> > > > > > > > So the concern is still the possible synchronize_expedited()?
> > > > > > > I think synchronize_srcu_expedited.
> > > > > > > 
> > > > > > > synchronize_expedited sends lots of IPI and is bad for realtime VMs.
> > > > > > > 
> > > > > > > > Can I do this
> > > > > > > > on through another series on top of the incoming V2?
> > > > > > > > 
> > > > > > > > Thanks
> > > > > > > > 
> > > > > > > The question is this: is this still a gain if we switch to the
> > > > > > > more expensive srcu? If yes then we can keep the feature on,
> > > > > > I think we only care about the cost on srcu_read_lock()
> > > > > > which looks pretty
> > > > > > tiny form my point of view. Which is basically a
> > > > > > READ_ONCE() + WRITE_ONCE().
> > > > > > 
> > > > > > Of course I can benchmark to see the difference.
> > > > > > 
> > > > > > 
> > > > > > > if not we'll put it off until next release and think
> > > > > > > of better solutions. rcu->srcu is just a find and replace,
> > > > > > > don't see why we need to defer that. can be a separate patch
> > > > > > > for sure, but we need to know how well it works.
> > > > > > I think I get here, let me try to do that in V2 and
> > > > > > let's see the numbers.
> > > > > > 
> > > > > > Thanks
> > > > 
> > > > It looks to me for tree rcu, its srcu_read_lock() have a mb()
> > > > which is too
> > > > expensive for us.
> > > I will try to ponder using vq lock in some way.
> > > Maybe with trylock somehow ...
> > 
> > 
> > Ok, let me retry if necessary (but I do remember I end up with deadlocks
> > last try).
> 
> 
> Ok, I play a little with this. And it works so far. Will do more testing
> tomorrow.
> 
> One reason could be I switch to use get_user_pages_fast() to
> __get_user_pages_fast() which doesn't need mmap_sem.
> 
> Thanks

OK that sounds good. If we also set a flag to make
vhost_exceeds_weight exit, then I think it will be all good.

-- 
MST

