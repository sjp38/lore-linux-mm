Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B44D5C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:28:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AC202080A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:28:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AC202080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0BEE6B0003; Tue, 18 Jun 2019 14:28:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBC9D8E0002; Tue, 18 Jun 2019 14:28:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAA708E0001; Tue, 18 Jun 2019 14:28:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B49E6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:28:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k15so22441318eda.6
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:28:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=D/4QLYjJPNIPk2S3bapsZPMqjJvGyGZ65VBzwqzk1/Q=;
        b=pNVGgWKNMrNwKgSxrn+QqKQwY0MreOZlRHwTHrXxLxy8MlmyfB+APFtiXqhqgM+/1E
         vDGBVfsxI19e4KP+5A84JOgx1nuAgm6pk5qa5zy2sUMA+oDhkf0GL3IKSs5hwG/64NFj
         1IOcdjfDTZByE2KHBNCWvBUc/DFZ3hKtQT0HhJ/gjVlH6h8opTFor458DrWdFEQ1eVFw
         FBMxhPBO7vzBDeHbRPQsQKsXsioCdTFTFoB2GHAjTtV00aYxgVZCEqKHpMyWUUu9Bb9W
         FLJ4YLrRUqTuQMv9Nktv4xxcI0Q+4xlTYljAtRxLh0lRoS4osMTrMUVpa5OO5gnmMgUI
         TvCQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXe+B/6p0ddxsa2jFQ651b+kwfFW4t8O8CjnsT9gSSJfGqrT4Wn
	GM4sKkwqE9pSozrVRDN5KundCm0WTE6An/HinwlrVgaL6+guXAd98efRLUfO8tzB1fCU5aMTBdV
	5kwTCbG4HlXIn18thhh4N+hYgt9/DjcoG8e7X/QHGKy1ehliNBPQBrxCxCSiapg8=
X-Received: by 2002:aa7:c313:: with SMTP id l19mr11960894edq.258.1560882531134;
        Tue, 18 Jun 2019 11:28:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4nrzWROZn2DnKvD3KXcXmEvfcc/MLSqmoxY3TlAcyXQ59FW+fP85V+ysJlZ+Dcdtqk0ic
X-Received: by 2002:aa7:c313:: with SMTP id l19mr11960803edq.258.1560882530222;
        Tue, 18 Jun 2019 11:28:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560882530; cv=none;
        d=google.com; s=arc-20160816;
        b=YkGwTwtHu94DXg7OsdmehVrHoLFmEzhtOuhQdEOgJ52raflKXqb8PrbjdnDZ//WCu8
         ldXL9p7kzOgbPf9UXYcNc9m1bceq9W7hcm0QLDSfF6QElzC0+CHIDwvACFzTKZkaXOs9
         iubKdHKSvt3RPeGKYKE6TJTSoBQQhIxN1pSMb0U3r7OSTKbV0SYkqe9zYys8bhZcWoQp
         v4FXdDbP+cy7nMRbo+isnbu2dLguX4AOQmbS7yl5hrZOvKCUBRK49SIZfk2YBXivoRwt
         7ygQdoQW5flZd/PQKmIdGcZpWXozsN0CrDoRXbKh2vVcd484aRnnvxEL6/Sx2cb0hvGk
         C7WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=D/4QLYjJPNIPk2S3bapsZPMqjJvGyGZ65VBzwqzk1/Q=;
        b=eMc0ENuAnyURtzCI6AT51nzQ8ODRcmqwv2eYE98orl5wdUvf0b3QHwrWCGmaEpg0PL
         UFZOAIneZoB7pnSu9VLftmrNNZ10QPM+QcivEhu7WTN7leVcufDBqYJ03AxRF2A5qwGp
         S9PGsJohkO4da+5kbO5q7w4seMJQO3r3eP97mV5bg/VgWeCXlIny/uUfzQczGZf/Y4a0
         jeit90JVtX6P4NLi5yL82m6bB8EdI4zfPiOhgsR1G4qj8oVjtl6Y+KzlGHVJtD5dmQaU
         BNmYU79c3s/J+qotjpoImzZgGn5GvkpIFCcxBJPMJK5q6PxooKSWKLPBkD7DrLbjUhFJ
         Ofww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e36si662865eda.321.2019.06.18.11.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 11:28:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5D800AE5D;
	Tue, 18 Jun 2019 18:28:49 +0000 (UTC)
Date: Tue, 18 Jun 2019 20:28:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Subject: Re: [PATCH] mm: mempolicy: handle vma with unmovable pages mapped
 correctly in mbind
Message-ID: <20190618182848.GJ3318@dhcp22.suse.cz>
References: <1560797290-42267-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190618130253.GH3318@dhcp22.suse.cz>
 <cf33b724-fdd5-58e3-c06a-1bc563525311@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf33b724-fdd5-58e3-c06a-1bc563525311@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 10:06:54, Yang Shi wrote:
> 
> 
> On 6/18/19 6:02 AM, Michal Hocko wrote:
> > [Cc networking people - see a question about setsockopt below]
> > 
> > On Tue 18-06-19 02:48:10, Yang Shi wrote:
> > > When running syzkaller internally, we ran into the below bug on 4.9.x
> > > kernel:
> > > 
> > > kernel BUG at mm/huge_memory.c:2124!
> > What is the BUG_ON because I do not see any BUG_ON neither in v4.9 nor
> > the latest stable/linux-4.9.y
> 
> The line number might be not exactly same with upstream 4.9 since there
> might be some our internal patches.
> 
> It is line 2096 at mm/huge_memory.c in 4.9.182.

So it is 
	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
that is later mentioned that has been removed. Good. Thanks for the
clarification!

> > > invalid opcode: 0000 [#1] SMP KASAN
> > [...]
> > > Code: c7 80 1c 02 00 e8 26 0a 76 01 <0f> 0b 48 c7 c7 40 46 45 84 e8 4c
> > > RIP  [<ffffffff81895d6b>] split_huge_page_to_list+0x8fb/0x1030 mm/huge_memory.c:2124
> > >   RSP <ffff88006899f980>
> > > 
> > > with the below test:
> > > 
> > > ---8<---
> > > 
> > > uint64_t r[1] = {0xffffffffffffffff};
> > > 
> > > int main(void)
> > > {
> > > 	syscall(__NR_mmap, 0x20000000, 0x1000000, 3, 0x32, -1, 0);
> > > 				intptr_t res = 0;
> > > 	res = syscall(__NR_socket, 0x11, 3, 0x300);
> > > 	if (res != -1)
> > > 		r[0] = res;
> > > *(uint32_t*)0x20000040 = 0x10000;
> > > *(uint32_t*)0x20000044 = 1;
> > > *(uint32_t*)0x20000048 = 0xc520;
> > > *(uint32_t*)0x2000004c = 1;
> > > 	syscall(__NR_setsockopt, r[0], 0x107, 0xd, 0x20000040, 0x10);
> > > 	syscall(__NR_mmap, 0x20fed000, 0x10000, 0, 0x8811, r[0], 0);
> > > *(uint64_t*)0x20000340 = 2;
> > > 	syscall(__NR_mbind, 0x20ff9000, 0x4000, 0x4002, 0x20000340,
> > > 0x45d4, 3);
> > > 	return 0;
> > > }
> > > 
> > > ---8<---
> > > 
> > > Actually the test does:
> > > 
> > > mmap(0x20000000, 16777216, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x20000000
> > > socket(AF_PACKET, SOCK_RAW, 768)        = 3
> > > setsockopt(3, SOL_PACKET, PACKET_TX_RING, {block_size=65536, block_nr=1, frame_size=50464, frame_nr=1}, 16) = 0
> > > mmap(0x20fed000, 65536, PROT_NONE, MAP_SHARED|MAP_FIXED|MAP_POPULATE|MAP_DENYWRITE, 3, 0) = 0x20fed000
> > > mbind(..., MPOL_MF_STRICT|MPOL_MF_MOVE) = 0
> > Ughh. Do I get it right that that this setsockopt allows an arbitrary
> > contiguous memory allocation size to be requested by a unpriviledged
> > user? Or am I missing something that restricts there any restriction?
> 
> It needs CAP_NET_RAW to call socket() to set socket type to RAW. The test is
> run by root user.

OK, good. That is much better. I just didn't see the capability check. I
can see one in packet_create but I do not see any in setsockopt. Maybe I
just got lost in indirection or implied security model.
 
[...]
> > > Change migrate_page_add() to check if the page is movable or not, if it
> > > is unmovable, just return -EIO.  We don't have to check non-LRU movable
> > > pages since just zsmalloc and virtio-baloon support this.  And, they
> > > should be not able to reach here.
> > You are not checking whether the page is movable, right? You only rely
> > on PageLRU check which is not really an equivalent thing. There are
> > movable pages which are not LRU and also pages might be off LRU
> > temporarily for many reasons so this could lead to false positives.
> 
> I'm supposed non-LRU movable pages could not reach here. Since most of them
> are not mmapable, i.e. virtio-balloon, zsmalloc. zram device is mmapable,
> but the page fault to that vma would end up allocating user space pages
> which are on LRU. If I miss something please let me know.

That might be true right now but it is a very subtle assumption that
might break easily in the future. The point is still that even LRU pages
might be isolated from the LRU list temporarily and you do not want this
to cause the failure easily.

-- 
Michal Hocko
SUSE Labs

