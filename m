Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15B25C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:19:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C24D320C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:19:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C24D320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48EBA8E0003; Wed, 27 Feb 2019 13:19:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43EDE8E0001; Wed, 27 Feb 2019 13:19:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32ED58E0003; Wed, 27 Feb 2019 13:19:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03FA08E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:19:52 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id i2so13812664ywb.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:19:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SG8+AwNO9pTDAwy0XmZ/9E7QFTB4ck31FCzRYixEZc8=;
        b=J3v6jYoTkqM0bpFndGE6sv/AjTwOP+5kDAVqKoXoJeWsPZlQ3BusYbiAMSBXwJjB7b
         YSGUftRCMF6WplmSN65PK1dLSwBj6EWHviOeC+oXpXDOm6fsqz2GvQm66MnYKJRbs5fW
         UOBtfIQLT+lmO87Ktlv9KXEF/Il+puJgxe/smHy9a4koB75TTKs6shY+qoZY0EFCSAHI
         1XqSptetqTs7Skjv81cYe/BKnukKBPr3aOl5pHEATUjACkmhH9DqPaGwOaRCpBmjY2Py
         H9rzcTi5avZLE18mF04EpCLU4/Xr9f8BPjeYY4+mjnKaltfGp9OsZ0vvZlRerxpeAmWK
         6vOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYvNJ+DPXZc68esUQwZGR//VbToQWKKM2MI/YKKYF5sxCJi4vQP
	o9HzzZv0VynbfnhRZv41NcBAnuraJ/v464EeuR4nYSfm3OqGJ8GEqEBGPu9OsWo43kwScUt5I4i
	3OuN8/WtIutLZZOrQ8baueORJF50OGsPr9s0bKwtJP+LR71ESZN8INO0icIcOavumoZzJ92/d4I
	vQWUaqxiBKi1t+0rx5OjoPcCHYxQlPWdvPwgN+8D/HkJ6dygkREAP8z9x007xzBnn0UlnxZ0HJ0
	/fdLcItHpgmPY/b/mcZK/k97vXEowcEQ4rwZipCoeB/WUhxUzVyjlIpYhvWL/9mu6y+kvE5JZbw
	99BYGVPE+LjJphzYnqTkvjKXYPQpkOAOZuVNAfxXT8G+GWAve2qvglMPPj1UtOZnqW8yoqoHIA=
	=
X-Received: by 2002:a81:4ed6:: with SMTP id c205mr2261332ywb.13.1551291591726;
        Wed, 27 Feb 2019 10:19:51 -0800 (PST)
X-Received: by 2002:a81:4ed6:: with SMTP id c205mr2261265ywb.13.1551291590848;
        Wed, 27 Feb 2019 10:19:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551291590; cv=none;
        d=google.com; s=arc-20160816;
        b=OHMHmQWS/7xahfkDxgCWJZhEqE6MO93idjlPVQSB1BNxygN6cBjYOc9E5GIkpiAhJG
         3t8nKvjGWuwo2YlX1wS13KDQrMfZ69A4Cj77kOs6w0UpwDl3NjR3Y9ADTH9syfG028ao
         9ajTWyVIsMd4W0tpvsIPR3jiL6/P+7Z8iGeQP4moId8kr0DVMUCWuR0l4t0pisbFr1Ei
         se4OcyYYjYNCCq4in9JmwuBQbHBJiK/1ks5SrMBm4+IA8sZgGwDgSEFeH+DxOUfV6qjB
         3vWbdT5OZCuDl+mQi3jZAqJRgUq+2wN0ID6jiI6xhac9UBOvP0hLDBTurKYrVMvkanrf
         BIkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=SG8+AwNO9pTDAwy0XmZ/9E7QFTB4ck31FCzRYixEZc8=;
        b=AK/jyVClRHOdvG93as4dFLJ1eernQmXXiWxel8+dpEyDWvQwBmSoE8aCokg60Bgxjl
         PxydOI1g9IbPGgPqd8y60+KGM0RQnMY3t89nTNvZJPBqS9oXWr/wg4/M8zQIc2hQnv16
         nKP/lSICKzsRNEq3BwlSrvwOmdhcVK+c9PiFA9Ml9gsQH6V8TQKKhjEcyjoLCk4cB0y8
         W6dqsW3qh60lvcJsYldWIpYL2UywjfSX9LkcpMGi8+HS/bDItXQs5e0QXM6/amdPiIzl
         5u5GroXWz2/0H7SFL8mJxv/SFpBzcHIrxieWMjUxu+PyXvPrMyrVIWxxMhagIUhu0JxM
         DkWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e123sor5814041ybb.190.2019.02.27.10.19.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 10:19:50 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IabMG2wZlD0xIC/0ylhor6WEZDf5f/MU5YKIBYq/mBQVHnHCJajvrImEanBXzHlNeazUyIn3g==
X-Received: by 2002:a25:d64e:: with SMTP id n75mr3059230ybg.199.1551291590453;
        Wed, 27 Feb 2019 10:19:50 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::3:8416])
        by smtp.gmail.com with ESMTPSA id s5sm5667824ywg.108.2019.02.27.10.19.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 10:19:49 -0800 (PST)
Date: Wed, 27 Feb 2019 13:19:47 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [RFC] percpu: decrease pcpu_nr_slots by 1
Message-ID: <20190227181947.GB2379@dennisz-mbp.dhcp.thefacebook.com>
References: <20190224092838.3417-1-peng.fan@nxp.com>
 <20190225152336.GC49611@dennisz-mbp.dhcp.thefacebook.com>
 <AM0PR04MB448161D9ED7D152AD58B53E9887B0@AM0PR04MB4481.eurprd04.prod.outlook.com>
 <20190226173238.GA51080@dennisz-mbp.dhcp.thefacebook.com>
 <AM0PR04MB44814BC1B03CC8D3963D969988740@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB44814BC1B03CC8D3963D969988740@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 01:33:15PM +0000, Peng Fan wrote:
> Hi Dennis,
> 
> > -----Original Message-----
> > From: Dennis Zhou [mailto:dennis@kernel.org]
> > Sent: 2019年2月27日 1:33
> > To: Peng Fan <peng.fan@nxp.com>
> > Cc: dennis@kernel.org; tj@kernel.org; cl@linux.com; linux-mm@kvack.org;
> > linux-kernel@vger.kernel.org; van.freenix@gmail.com
> > Subject: Re: [RFC] percpu: decrease pcpu_nr_slots by 1
> > 
> > On Tue, Feb 26, 2019 at 12:09:28AM +0000, Peng Fan wrote:
> > > Hi Dennis,
> > >
> > > > -----Original Message-----
> > > > From: dennis@kernel.org [mailto:dennis@kernel.org]
> > > > Sent: 2019年2月25日 23:24
> > > > To: Peng Fan <peng.fan@nxp.com>
> > > > Cc: tj@kernel.org; cl@linux.com; linux-mm@kvack.org;
> > > > linux-kernel@vger.kernel.org; van.freenix@gmail.com
> > > > Subject: Re: [RFC] percpu: decrease pcpu_nr_slots by 1
> > > >
> > > > On Sun, Feb 24, 2019 at 09:17:08AM +0000, Peng Fan wrote:
> > > > > Entry pcpu_slot[pcpu_nr_slots - 2] is wasted with current code logic.
> > > > > pcpu_nr_slots is calculated with `__pcpu_size_to_slot(size) + 2`.
> > > > > Take pcpu_unit_size as 1024 for example, __pcpu_size_to_slot will
> > > > > return max(11 - PCPU_SLOT_BASE_SHIFT + 2, 1), it is 8, so the
> > > > > pcpu_nr_slots will be 10.
> > > > >
> > > > > The chunk with free_bytes 1024 will be linked into pcpu_slot[9].
> > > > > However free_bytes in range [512,1024) will be linked into
> > > > > pcpu_slot[7], because `fls(512) - PCPU_SLOT_BASE_SHIFT + 2` is 7.
> > > > > So pcpu_slot[8] is has no chance to be used.
> > > > >
> > > > > According comments of PCPU_SLOT_BASE_SHIFT, 1~31 bytes share the
> > > > same
> > > > > slot and PCPU_SLOT_BASE_SHIFT is defined as 5. But actually 1~15
> > > > > share the same slot 1 if we not take PCPU_MIN_ALLOC_SIZE into
> > > > > consideration,
> > > > > 16~31 share slot 2. Calculation as below:
> > > > > highbit = fls(16) -> highbit = 5
> > > > > max(5 - PCPU_SLOT_BASE_SHIFT + 2, 1) equals 2, not 1.
> > > > >
> > > > > This patch by decreasing pcpu_nr_slots to avoid waste one slot and
> > > > > let [PCPU_MIN_ALLOC_SIZE, 31) really share the same slot.
> > > > >
> > > > > Signed-off-by: Peng Fan <peng.fan@nxp.com>
> > > > > ---
> > > > >
> > > > > V1:
> > > > >  Not very sure about whether it is intended to leave the slot there.
> > > > >
> > > > >  mm/percpu.c | 4 ++--
> > > > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > > >
> > > > > diff --git a/mm/percpu.c b/mm/percpu.c index
> > > > > 8d9933db6162..12a9ba38f0b5 100644
> > > > > --- a/mm/percpu.c
> > > > > +++ b/mm/percpu.c
> > > > > @@ -219,7 +219,7 @@ static bool pcpu_addr_in_chunk(struct
> > > > > pcpu_chunk *chunk, void *addr)  static int __pcpu_size_to_slot(int size)
> > {
> > > > >  	int highbit = fls(size);	/* size is in bytes */
> > > > > -	return max(highbit - PCPU_SLOT_BASE_SHIFT + 2, 1);
> > > > > +	return max(highbit - PCPU_SLOT_BASE_SHIFT + 1, 1);
> > > > >  }
> > > >
> > > > Honestly, it may be better to just have [1-16) [16-31) be separate.
> 
> Missed to reply this in previous thread, the following comments let
> me think the chunk slot calculation might be wrong, so this comment
> needs to be updated, saying "[PCPU_MIN_ALLOC_SIZE - 15) bytes share
> the same slot", if [1-16)[16-31) is expected.
> "
> /* the slots are sorted by free bytes left, 1-31 bytes share the same slot */
> #define PCPU_SLOT_BASE_SHIFT            5
> "
> 
> > > > I'm working on a change to this area, so I may change what's going on
> > here.
> > > >
> > > > >
> > > > >  static int pcpu_size_to_slot(int size) @@ -2145,7 +2145,7 @@ int
> > > > > __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
> > > > >  	 * Allocate chunk slots.  The additional last slot is for
> > > > >  	 * empty chunks.
> > > > >  	 */
> > > > > -	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
> > > > > +	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 1;
> > > > >  	pcpu_slot = memblock_alloc(pcpu_nr_slots * sizeof(pcpu_slot[0]),
> > > > >  				   SMP_CACHE_BYTES);
> > > > >  	for (i = 0; i < pcpu_nr_slots; i++)
> > > > > --
> > > > > 2.16.4
> > > > >
> > > >
> > > > This is a tricky change. The nice thing about keeping the additional
> > > > slot around is that it ensures a distinction between a completely
> > > > empty chunk and a nearly empty chunk.
> > >
> > > Are there any issues met before if not keeping the unused slot?
> > > From reading the code and git history I could not find information.
> > > I tried this code on aarch64 qemu and did not meet issues.
> > >
> > 
> > This change would require verification that all paths lead to power of 2 chunk
> > sizes and most likely a BUG_ON if that's not the case.
> 
> I try to understand, "power of 2 chunk sizes", you mean the runtime free_bytes
> of a chunk?
> 

I'm talking about the unit_size.

> > 
> > So while this would work, we're holding onto an additional slot also to be used
> > for chunk reclamation via pcpu_balance_workfn(). If a chunk was not a power
> > of 2 resulting in the last slot being entirely empty chunks we could free stuff a
> > chunk with addresses still in use.
> 
> You mean the following code might free stuff when a percpu variable is still being used
> if the chunk runtime free_bytes is not a power of 2?
> "
> 1623         list_for_each_entry_safe(chunk, next, &to_free, list) {
> 1624                 int rs, re;
> 1625
> 1626                 pcpu_for_each_pop_region(chunk->populated, rs, re, 0,
> 1627                                          chunk->nr_pages) {
> 1628                         pcpu_depopulate_chunk(chunk, rs, re);
> 1629                         spin_lock_irq(&pcpu_lock);
> 1630                         pcpu_chunk_depopulated(chunk, rs, re);
> 1631                         spin_unlock_irq(&pcpu_lock);
> 1632                 }
> 1633                 pcpu_destroy_chunk(chunk);
> 1634                 cond_resched();
> 1635         }
> "
> 

Yes, if the unit_size is not a power of 2, then the last slot holds used
chunks.

> > 
> > > > It happens to be that the logic creates power of 2 chunks which ends
> > > > up being an additional slot anyway.
> > >
> > >
> > > So,
> > > > given that this logic is tricky and architecture dependent,
> > >
> > > Could you share more information about architecture dependent?
> > >
> > 
> > The crux of the logic is in pcpu_build_alloc_info(). It's been some time since
> > I've thought deeply about it, but I don't believe there is a guarantee that it will
> > be a power of 2 chunk.
> 
> I am a bit lost about a power of 2, need to read more about the code.
> 

I'm reluctant to remove this slot because it is tricky code and the
benefit of it is negligible compared to the risk.

Thanks,
Dennis

