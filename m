Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13012C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:45:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B753B21880
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:45:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B753B21880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50DAD8E001A; Wed, 24 Jul 2019 19:45:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BECE8E0002; Wed, 24 Jul 2019 19:45:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AD8B8E001A; Wed, 24 Jul 2019 19:45:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F33938E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:45:12 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so29604900pfd.3
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:45:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=XVkfIRAYFJplrbWlBcm8aMrnu6EAqtcSwohxAlqtjFo=;
        b=CXedrkBV8lRV6O5Vlmlt4+kn+LhcyVD4MTLAruHX+Px6uuZ3ueoEuwiMtsHTUFVMbk
         VawPCoI8G48EUi+ZrW56a6+Mc7730iwuiE9dAovuFoQR858MVh45031Sr5WHbpZN5dsU
         bB5mg0Q8+sJXKsLsR5tN6OXMsTIudsYESJ4oZg6u0zQ2hDNd4/lD95wrNc9ZvwG/kBM8
         KmKop4hmIXka37TPUPWQhA1/wBUuHfRvC2wpVar+Z7B54NJyC363CuEzoZzM52OzGKPY
         MAU7iMVFS+2XY9KisIy+S5h8ISg8Z2yDruIAnpo81KmQW3LS9r0iSvC1WhAIGTjXfy+w
         BXsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAVQJ96ahw21moBdNTn9WodG4l947oZfdg8IhG5XwoNUQRGOInpz
	GEPRtjQ+fUCckDUgau7p2gIzZ6WGdjH8/Kh1P8a9QqmGIoErwAKIQwWVHYL3iPhopIlCFbTGohG
	IqCP/Sp2P14iqrP01m4jIOTQJOpbDQahg82Z8AW5VflOncIGFkCb9YmD8noalreaQzw==
X-Received: by 2002:a63:4f51:: with SMTP id p17mr61751496pgl.333.1564011912451;
        Wed, 24 Jul 2019 16:45:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVyyK3hiEYY87Lqr5hKlNOunZWBEaMm+npaKBCNrOMFukXiqrSO1L4MRqpqqTemiTVLEMS
X-Received: by 2002:a63:4f51:: with SMTP id p17mr61751428pgl.333.1564011911438;
        Wed, 24 Jul 2019 16:45:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564011911; cv=none;
        d=google.com; s=arc-20160816;
        b=Tb8HThE1ixjWTKw8vkzX6sjh08GJoP3hRSS4M8RRPpqyNN7X8TYdAFNh+On0hJlU4c
         bgydUS/QFGONpRqmurX282zSSnsD+MLYpLKcSSqa8osdhIqrqX/zBsFXNvUbOHFqg1Pq
         FA1jikNmE9Mw9dnux/fQm1DtT1Ruz3ZLF1XJDJI2ep+xwvTNSutPilFh/V2tP1Ogf9R4
         SnB2q16Aj9DN/5ui9BhcIpN0z1z5Pf2uBQ4gHjCLZQI1oWC4Hd6y6i7Nad+gjQ4seqKi
         31dvUz0eCU2TYcugVyUf866CWNkVRIN15T+Rzij4xgz2o79qfOUI6zxEsl2LXBYllyvA
         Kf0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=XVkfIRAYFJplrbWlBcm8aMrnu6EAqtcSwohxAlqtjFo=;
        b=GJXROb6Uj8SxpFHCTBEdQAFcCygS2CzXB+Dz30unmT6qadXKNNTln8g1xpdKcpH+m4
         H+4z6XGeKWtC+ANY3HE7lH8ai3Ea029JDKJteDkEZ2h7EGulBoprhMbC6j4G6jXiJY3l
         UWiWSNszdgN0oL96olCkGxDhvDj5+8aqZ7qG9cwiIG9XSr/FvJ/PiGoGXdYNj7UPGPJc
         hajocfs6CRCLewsU2qFgkfL60kPabcZvIcrEFbp+qtMMTkzd78ZT4B10vu8Xtrmcg3tC
         Rx57G94uxuRZHEAmzP1N/dNxNXdXt8HPIOsgZwufcZ4Fk2/qeDdBKLn+bCBrrl3kwasK
         1dag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id z142si16223396pfc.128.2019.07.24.16.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 16:45:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x6ONj90V029079
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 25 Jul 2019 08:45:09 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6ONj9Vd028359;
	Thu, 25 Jul 2019 08:45:09 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6ONe3aT011021;
	Thu, 25 Jul 2019 08:45:09 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.152] [10.38.151.152]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7087570; Thu, 25 Jul 2019 08:43:26 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC24GP.gisp.nec.co.jp ([10.38.151.152]) with mapi id 14.03.0439.000; Thu,
 25 Jul 2019 08:43:25 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Jane Chu <jane.chu@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH v2 1/1] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
Thread-Topic: [PATCH v2 1/1] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
Thread-Index: AQHVQnAjSKtp5HUwfEeIsgIKjFcsrqbZ12MA
Date: Wed, 24 Jul 2019 23:43:25 +0000
Message-ID: <20190724234318.GA21820@hori.linux.bs1.fc.nec.co.jp>
References: <1564007603-9655-1-git-send-email-jane.chu@oracle.com>
 <1564007603-9655-2-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1564007603-9655-2-git-send-email-jane.chu@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1F5511DB107F864C919C1A6A91C4628E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 04:33:23PM -0600, Jane Chu wrote:
> Mmap /dev/dax more than once, then read the poison location using address
> from one of the mappings. The other mappings due to not having the page
> mapped in will cause SIGKILLs delivered to the process. SIGKILL succeeds
> over SIGBUS, so user process looses the opportunity to handle the UE.
>=20
> Although one may add MAP_POPULATE to mmap(2) to work around the issue,
> MAP_POPULATE makes mapping 128GB of pmem several magnitudes slower, so
> isn't always an option.
>=20
> Details -
>=20
> ndctl inject-error --block=3D10 --count=3D1 namespace6.0
>=20
> ./read_poison -x dax6.0 -o 5120 -m 2
> mmaped address 0x7f5bb6600000
> mmaped address 0x7f3cf3600000
> doing local read at address 0x7f3cf3601400
> Killed
>=20
> Console messages in instrumented kernel -
>=20
> mce: Uncorrected hardware memory error in user-access at edbe201400
> Memory failure: tk->addr =3D 7f5bb6601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> dev_pagemap_mapping_shift: page edbe201: no PUD
> Memory failure: tk->size_shift =3D=3D 0
> Memory failure: Unable to find user space address edbe201 in read_poison
> Memory failure: tk->addr =3D 7f3cf3601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> Memory failure: tk->size_shift =3D 21
> Memory failure: 0xedbe201: forcibly killing read_poison:22434 because of =
failure to unmap corrupted page
>   =3D> to deliver SIGKILL
> Memory failure: 0xedbe201: Killing read_poison:22434 due to hardware memo=
ry corruption
>   =3D> to deliver SIGBUS
>=20
> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 62 ++++++++++++++++++++++-------------------------=
------
>  1 file changed, 26 insertions(+), 36 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d9cc660..bd4db33 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -199,7 +199,6 @@ struct to_kill {
>  	struct task_struct *tsk;
>  	unsigned long addr;
>  	short size_shift;
> -	char addr_valid;
>  };
> =20
>  /*
> @@ -304,43 +303,43 @@ static unsigned long dev_pagemap_mapping_shift(stru=
ct page *page,
>  /*
>   * Schedule a process for later kill.
>   * Uses GFP_ATOMIC allocations to avoid potential recursions in the VM.
> - * TBD would GFP_NOIO be enough?
>   */
>  static void add_to_kill(struct task_struct *tsk, struct page *p,
>  		       struct vm_area_struct *vma,
> -		       struct list_head *to_kill,
> -		       struct to_kill **tkc)
> +		       struct list_head *to_kill)
>  {
>  	struct to_kill *tk;
> =20
> -	if (*tkc) {
> -		tk =3D *tkc;
> -		*tkc =3D NULL;
> -	} else {
> -		tk =3D kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
> -		if (!tk) {
> -			pr_err("Memory failure: Out of memory while machine check handling\n"=
);
> -			return;
> -		}
> +	tk =3D kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
> +	if (!tk) {
> +		pr_err("Memory failure: Out of memory while machine check handling\n")=
;
> +		return;

As Dan pointed out, the cleanup part can be delivered as a separate patch.

>  	}
> +
>  	tk->addr =3D page_address_in_vma(p, vma);
> -	tk->addr_valid =3D 1;
>  	if (is_zone_device_page(p))
>  		tk->size_shift =3D dev_pagemap_mapping_shift(p, vma);
>  	else
>  		tk->size_shift =3D compound_order(compound_head(p)) + PAGE_SHIFT;
> =20
>  	/*
> -	 * In theory we don't have to kill when the page was
> -	 * munmaped. But it could be also a mremap. Since that's
> -	 * likely very rare kill anyways just out of paranoia, but use
> -	 * a SIGKILL because the error is not contained anymore.
> +	 * Send SIGKILL if "tk->addr =3D=3D -EFAULT". Also, as
> +	 * "tk->size_shift" is always non-zero for !is_zone_device_page(),
> +	 * so "tk->size_shift =3D=3D 0" effectively checks no mapping on
> +	 * ZONE_DEVICE. Indeed, when a devdax page is mmapped N times
> +	 * to a process' address space, it's possible not all N VMAs
> +	 * contain mappings for the page, but at least one VMA does.
> +	 * Only deliver SIGBUS with payload derived from the VMA that
> +	 * has a mapping for the page.

OK, so SIGBUSs are sent M times (where M is the number of mappings
for the page). Then I'm convinced that we need "else if" block below.

Thanks,
Naoya Horiguchi

>  	 */
> -	if (tk->addr =3D=3D -EFAULT || tk->size_shift =3D=3D 0) {
> +	if (tk->addr =3D=3D -EFAULT) {
>  		pr_info("Memory failure: Unable to find user space address %lx in %s\n=
",
>  			page_to_pfn(p), tsk->comm);
> -		tk->addr_valid =3D 0;
> +	} else if (tk->size_shift =3D=3D 0) {
> +		kfree(tk);
> +		return;
>  	}
> +
>  	get_task_struct(tsk);
>  	tk->tsk =3D tsk;
>  	list_add_tail(&tk->nd, to_kill);
> @@ -366,7 +365,7 @@ static void kill_procs(struct list_head *to_kill, int=
 forcekill, bool fail,
>  			 * make sure the process doesn't catch the
>  			 * signal and then access the memory. Just kill it.
>  			 */
> -			if (fail || tk->addr_valid =3D=3D 0) {
> +			if (fail || tk->addr =3D=3D -EFAULT) {
>  				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of fail=
ure to unmap corrupted page\n",
>  				       pfn, tk->tsk->comm, tk->tsk->pid);
>  				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
> @@ -432,7 +431,7 @@ static struct task_struct *task_early_kill(struct tas=
k_struct *tsk,
>   * Collect processes when the error hit an anonymous page.
>   */
>  static void collect_procs_anon(struct page *page, struct list_head *to_k=
ill,
> -			      struct to_kill **tkc, int force_early)
> +				int force_early)
>  {
>  	struct vm_area_struct *vma;
>  	struct task_struct *tsk;
> @@ -457,7 +456,7 @@ static void collect_procs_anon(struct page *page, str=
uct list_head *to_kill,
>  			if (!page_mapped_in_vma(page, vma))
>  				continue;
>  			if (vma->vm_mm =3D=3D t->mm)
> -				add_to_kill(t, page, vma, to_kill, tkc);
> +				add_to_kill(t, page, vma, to_kill);
>  		}
>  	}
>  	read_unlock(&tasklist_lock);
> @@ -468,7 +467,7 @@ static void collect_procs_anon(struct page *page, str=
uct list_head *to_kill,
>   * Collect processes when the error hit a file mapped page.
>   */
>  static void collect_procs_file(struct page *page, struct list_head *to_k=
ill,
> -			      struct to_kill **tkc, int force_early)
> +				int force_early)
>  {
>  	struct vm_area_struct *vma;
>  	struct task_struct *tsk;
> @@ -492,7 +491,7 @@ static void collect_procs_file(struct page *page, str=
uct list_head *to_kill,
>  			 * to be informed of all such data corruptions.
>  			 */
>  			if (vma->vm_mm =3D=3D t->mm)
> -				add_to_kill(t, page, vma, to_kill, tkc);
> +				add_to_kill(t, page, vma, to_kill);
>  		}
>  	}
>  	read_unlock(&tasklist_lock);
> @@ -501,26 +500,17 @@ static void collect_procs_file(struct page *page, s=
truct list_head *to_kill,
> =20
>  /*
>   * Collect the processes who have the corrupted page mapped to kill.
> - * This is done in two steps for locking reasons.
> - * First preallocate one tokill structure outside the spin locks,
> - * so that we can kill at least one process reasonably reliable.
>   */
>  static void collect_procs(struct page *page, struct list_head *tokill,
>  				int force_early)
>  {
> -	struct to_kill *tk;
> -
>  	if (!page->mapping)
>  		return;
> =20
> -	tk =3D kmalloc(sizeof(struct to_kill), GFP_NOIO);
> -	if (!tk)
> -		return;
>  	if (PageAnon(page))
> -		collect_procs_anon(page, tokill, &tk, force_early);
> +		collect_procs_anon(page, tokill, force_early);
>  	else
> -		collect_procs_file(page, tokill, &tk, force_early);
> -	kfree(tk);
> +		collect_procs_file(page, tokill, force_early);
>  }
> =20
>  static const char *action_name[] =3D {
> --=20
> 1.8.3.1
>=20
> =

