Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F356C49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 17:51:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13EE9208E4
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 17:51:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NUuUl+ZG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13EE9208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AC886B0007; Tue, 10 Sep 2019 13:51:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85CF06B0008; Tue, 10 Sep 2019 13:51:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74BBE6B000C; Tue, 10 Sep 2019 13:51:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id 5378D6B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 13:51:23 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BCAB4702
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 17:51:22 +0000 (UTC)
X-FDA: 75919752804.10.shoe83_805c59fea8c5c
X-HE-Tag: shoe83_805c59fea8c5c
X-Filterd-Recvd-Size: 11887
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 17:51:21 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id n9so10135900pgc.1
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:51:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=ODqZ9n1vKHk7brPymQ0c7LOZlUGTdz8sVkCHwqasHmQ=;
        b=NUuUl+ZG+81W3AguoSBU9puBDdWsRnLDF4eDUxmn0u2MrW5l27NWYoCjgfoRLFlon2
         is4ZIblk2cbs+0GCnMXrgQi4JRnA3gcrmPJhEq/EnMylq9z/498Xa/hwV/fc0F8O8Z0x
         OPYHkxpbXPodaRvnFKNwJFO4eK505wgV/Pj76+8/qpjlku8K91X7TwffAIeG3zjWvo/A
         +5Pom/Q6j43IeXsLaZkqDwdyvvRs0Yxo6gyyIvbLPR+swTyLsecN4ZAV8TfSuBSeQb0l
         zPYNs5tfo6K3SGY9C5bpOpJu1QO0aSevenZJh6RScFg//0LcFCr52Mz0+66Z6Snydyt6
         Facw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ODqZ9n1vKHk7brPymQ0c7LOZlUGTdz8sVkCHwqasHmQ=;
        b=WuDgZ0wYwSPorjZihNmO+ka83tetqNxGlG7MAdmKTCOSIJp7WaJ6so68tjrtP/Qssj
         UwzyQ6jcQOJ6IUqWyskydYlNwDgp+2M5lvW9KbcekfRCFm98wa2bx7mba9i3Kx9i6M25
         jB6MJczOZLhH2g3llW54zfMdcI1Z3u58oPkOP9baLCwPsZeAW3uxCIJuEu4llOqYCKBU
         ULICDNsiiCE0Q+kRBkPR+zeP1UyUszdVxPuUqVpfXCFxb+8qGL+3KtZLiBwAliMJltWC
         F8E+6f0bABy66AZ03fpRA48aQy8gmYywacfikfDdXui2dYNV4slfXXCbpC9lfzfk43QU
         krZA==
X-Gm-Message-State: APjAAAX7VVT6RDf1ZVU4FHs8P1+wxvtZ6TXCmrvH1bTQBn3QFZzOLjpd
	SQsEEf4ifK+L58G3E6mEbjY=
X-Google-Smtp-Source: APXvYqz7hoSrn0h/VAEk4dWhjnzbITbGusSvo65Nw2LFsQyhDA6Oil7l8Y4BknSChWtYIMKhHMHP+w==
X-Received: by 2002:a63:195f:: with SMTP id 31mr29455108pgz.225.1568137880638;
        Tue, 10 Sep 2019 10:51:20 -0700 (PDT)
Received: from google.com ([2620:15c:211:1:3e01:2939:5992:52da])
        by smtp.gmail.com with ESMTPSA id r23sm302607pjo.22.2019.09.10.10.51.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Sep 2019 10:51:19 -0700 (PDT)
Date: Tue, 10 Sep 2019 10:51:16 -0700
From: Minchan Kim <minchan@kernel.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
Message-ID: <20190910175116.GB39783@google.com>
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190909232613.GA39783@google.com>
 <9df3bb51-2094-c849-8171-dce6784e1e70@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <9df3bb51-2094-c849-8171-dce6784e1e70@codeaurora.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 01:52:36PM +0530, Vinayak Menon wrote:
> Hi Minchan,
>=20
>=20
> On 9/10/2019 4:56 AM, Minchan Kim wrote:
> > Hi Vinayak,
> >
> > On Fri, Aug 30, 2019 at 06:13:31PM +0530, Vinayak Menon wrote:
> >> The following race is observed due to which a processes faulting
> >> on a swap entry, finds the page neither in swapcache nor swap. This
> >> causes zram to give a zero filled page that gets mapped to the
> >> process, resulting in a user space crash later.
> >>
> >> Consider parent and child processes Pa and Pb sharing the same swap
> >> slot with swap_count 2. Swap is on zram with SWP_SYNCHRONOUS_IO set.
> >> Virtual address 'VA' of Pa and Pb points to the shared swap entry.
> >>
> >> Pa                                       Pb
> >>
> >> fault on VA                              fault on VA
> >> do_swap_page                             do_swap_page
> >> lookup_swap_cache fails                  lookup_swap_cache fails
> >>                                          Pb scheduled out
> >> swapin_readahead (deletes zram entry)
> >> swap_free (makes swap_count 1)
> >>                                          Pb scheduled in
> >>                                          swap_readpage (swap_count =3D=
=3D 1)
> >>                                          Takes SWP_SYNCHRONOUS_IO pa=
th
> >>                                          zram enrty absent
> >>                                          zram gives a zero filled pa=
ge
> >>
> >> Fix this by reading the swap_count before lookup_swap_cache, which c=
onforms
> >> with the order in which page is added to swap cache and swap count i=
s
> >> decremented in do_swap_page. In the race case above, this will let P=
b take
> >> the readahead path and thus pick the proper page from swapcache.
> > Thanks for the report, Vinayak.
> >
> > It's a zram specific issue because it deallocates zram block
> > unconditionally once read IO is done. The expectation was that dirty
> > page is on the swap cache but with SWP_SYNCHRONOUS_IO, it's not true
> > any more so I want to resolve the issue in zram specific code, not
> > general one.
>=20
>=20
> Thanks for comments Minchan.
>=20
> Trying to understand your comment better.=A0 With SWP_SYNCHRONOUS_IO al=
so, swap_slot_free_notify will
>=20
> make sure that it deletes the entry only if the page is in swapcache. E=
ven in the current issue case, a valid
>=20
> entry is present in the swapcache at the time of issue (brought in by P=
a). Its just that Pb missed it due to the
>=20
> race and tried to read again from zram. So thinking whether it is an is=
sue with zram deleting the entry, or
>=20
> SWP_SYNCHRONOUS_IO failing to find the valid swapcache entry. There isn=
't actually a case seen where zram
>=20
> entry is deleted unconditionally, with some process yet to reference th=
e slot and page is not in swapcache.
>=20
>=20
> >
> > A idea in my mind is swap_slot_free_notify should check the slot
> > reference counter and if it's higher than 1, it shouldn't free the
> > slot until. What do you think about?
>=20
> It seems fine to me except for the fact that it will delay zram entry d=
eletion for shared slots, which
>=20
> can be significant sometimes. Also, should we fix this path as the issu=
e is with SWP_SYNCHRONOUS_IO missing

It's always trade-off between memory vs performance since it could hit
in swap cache. If it's shared page, it's likely to hit a cache next time
so we could get performance benefit.

Actually, swap_slot_free_notify is layering violation so I wanted to
replace it with discard hint in the long run so want to go the direction.

>=20
> a valid swapcache entry ?
>=20
> Can swapcache check be done like below, before taking the SWP_SYNCHRONO=
US_IO path, as an alternative ?

With your approach, what prevent below scenario?

A                                                       B

                                            do_swap_page
                                            SWP_SYNCHRONOUS_IO && __swap_=
count =3D=3D 1
shrink_page_list
add_to_swap
    swap_count =3D 2

..
..
do_swap_page
swap_read
    swap_slot_free_notify
        zram's slot will be removed
                                            page =3D alloc_page_vma
                                            swap_readpage <-- read zero


>=20
>=20
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 063c0c1..a5ca05f 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -463,6 +463,7 @@ extern sector_t map_swap_page(struct page *, struct=
 block_device **);
> =A0extern sector_t swapdev_block(int, pgoff_t);
> =A0extern int page_swapcount(struct page *);
> =A0extern int __swap_count(swp_entry_t entry);
> +extern bool __swap_has_cache(swp_entry_t entry);
> =A0extern int __swp_swapcount(swp_entry_t entry);
> =A0extern int swp_swapcount(swp_entry_t entry);
> =A0extern struct swap_info_struct *page_swap_info(struct page *);
> @@ -589,6 +590,11 @@ static inline int __swap_count(swp_entry_t entry)
> =A0=A0=A0=A0=A0=A0=A0 return 0;
> =A0}
>=20
> +static bool __swap_has_cache(swp_entry_t entry)
> +{
> +=A0=A0=A0=A0=A0=A0 return 0;
> +}
> +
> =A0static inline int __swp_swapcount(swp_entry_t entry)
> =A0{
> =A0=A0=A0=A0=A0=A0=A0 return 0;
>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index e0c232f..a13511f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2778,7 +2778,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 struct swap_info_struct *=
si =3D swp_swap_info(entry);
>=20
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (si->flags & SWP_SYNCH=
RONOUS_IO &&
> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 __swap_count(entry) =3D=3D 1) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 __swap_count(entry) =3D=3D 1 &&
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 !__swap_has_cache(entry)) {
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /=
* skip swapcache */
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 p=
age =3D alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 vmf->address);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 80445f4..2a1554a8 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1459,6 +1459,20 @@ int __swap_count(swp_entry_t entry)
> =A0=A0=A0=A0=A0=A0=A0 return count;
> =A0}
>=20
> +bool __swap_has_cache(swp_entry_t entry)
> +{
> +=A0=A0=A0=A0=A0=A0 struct swap_info_struct *si;
> +=A0=A0=A0=A0=A0=A0 pgoff_t offset =3D swp_offset(entry);
> +=A0=A0=A0=A0=A0=A0 bool has_cache=A0 =3D false;
> +
> +=A0=A0=A0=A0=A0=A0 si =3D get_swap_device(entry);
> +=A0=A0=A0=A0=A0=A0 if (si) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 has_cache =3D !!(si->swap_m=
ap[offset] & SWAP_HAS_CACHE);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 put_swap_device(si);
> +=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 return has_cache;
> +}
> +
> =A0static int swap_swapcount(struct swap_info_struct *si, swp_entry_t e=
ntry)
> =A0{
> =A0=A0=A0=A0=A0=A0=A0 int count =3D 0;
>=20
>=20
> >
> >> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> >> ---
> >>  mm/memory.c | 21 ++++++++++++++++-----
> >>  1 file changed, 16 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/mm/memory.c b/mm/memory.c
> >> index e0c232f..22643aa 100644
> >> --- a/mm/memory.c
> >> +++ b/mm/memory.c
> >> @@ -2744,6 +2744,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
> >>  	struct page *page =3D NULL, *swapcache;
> >>  	struct mem_cgroup *memcg;
> >>  	swp_entry_t entry;
> >> +	struct swap_info_struct *si;
> >> +	bool skip_swapcache =3D false;
> >>  	pte_t pte;
> >>  	int locked;
> >>  	int exclusive =3D 0;
> >> @@ -2771,15 +2773,24 @@ vm_fault_t do_swap_page(struct vm_fault *vmf=
)
> >> =20
> >> =20
> >>  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> >> +
> >> +	/*
> >> +	 * lookup_swap_cache below can fail and before the SWP_SYNCHRONOUS=
_IO
> >> +	 * check is made, another process can populate the swapcache, dele=
te
> >> +	 * the swap entry and decrement the swap count. So decide on takin=
g
> >> +	 * the SWP_SYNCHRONOUS_IO path before the lookup. In the event of =
the
> >> +	 * race described, the victim process will find a swap_count > 1
> >> +	 * and can then take the readahead path instead of SWP_SYNCHRONOUS=
_IO.
> >> +	 */
> >> +	si =3D swp_swap_info(entry);
> >> +	if (si->flags & SWP_SYNCHRONOUS_IO && __swap_count(entry) =3D=3D 1=
)
> >> +		skip_swapcache =3D true;
> >> +
> >>  	page =3D lookup_swap_cache(entry, vma, vmf->address);
> >>  	swapcache =3D page;
> >> =20
> >>  	if (!page) {
> >> -		struct swap_info_struct *si =3D swp_swap_info(entry);
> >> -
> >> -		if (si->flags & SWP_SYNCHRONOUS_IO &&
> >> -				__swap_count(entry) =3D=3D 1) {
> >> -			/* skip swapcache */
> >> +		if (skip_swapcache) {
> >>  			page =3D alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
> >>  							vmf->address);
> >>  			if (page) {
> >> --=20
> >> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> >> member of the Code Aurora Forum, hosted by The Linux Foundation
> >>

