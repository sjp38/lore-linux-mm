Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0743EC433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 03:54:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 966932067D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 03:54:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 966932067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DE726B0007; Wed, 14 Aug 2019 23:54:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28F086B0008; Wed, 14 Aug 2019 23:54:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A3F46B000A; Wed, 14 Aug 2019 23:54:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id E80266B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 23:54:09 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8F427180AD801
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:54:09 +0000 (UTC)
X-FDA: 75823294218.02.cork05_2414fec10d038
X-HE-Tag: cork05_2414fec10d038
X-Filterd-Recvd-Size: 9437
Received: from r3-11.sinamail.sina.com.cn (r3-11.sinamail.sina.com.cn [202.108.3.11])
	by imf15.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:54:07 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([221.219.6.224])
	by sina.com with ESMTP
	id 5D54D75A00031188; Thu, 15 Aug 2019 11:54:04 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 98808650999688
From: Hillf Danton <hdanton@sina.com>
To: Mina Almasry <almasrymina@google.com>
Cc: mike.kravetz@oracle.com,
	shuah@kernel.org,
	rientjes@google.com,
	shakeelb@google.com,
	gthelen@google.com,
	akpm@linux-foundation.org,
	khalid.aziz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [RFC PATCH v2 1/5] hugetlb_cgroup: Add hugetlb_cgroup reservation counter
Date: Thu, 15 Aug 2019 11:53:52 +0800
Message-Id: <20190815035352.14952-1-hdanton@sina.com>
In-Reply-To: <20190808231340.53601-1-almasrymina@google.com>
References: 
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu,  8 Aug 2019 16:13:36 -0700 Mina Almasry wrote:
>=20
> These counters will track hugetlb reservations rather than hugetlb
> memory faulted in. This patch only adds the counter, following patches
> add the charging and uncharging of the counter.
> ---

  !?!

>  include/linux/hugetlb.h |  2 +-
>  mm/hugetlb_cgroup.c     | 86 +++++++++++++++++++++++++++++++++++++----
>  2 files changed, 80 insertions(+), 8 deletions(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index edfca42783192..6777b3013345d 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -340,7 +340,7 @@ struct hstate {
>  	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
>  #ifdef CONFIG_CGROUP_HUGETLB
>  	/* cgroup control files */
> -	struct cftype cgroup_files[5];
> +	struct cftype cgroup_files[9];

Move that enum in this header file and replace numbers with characters
to easy both reading and maintaining.
>  #endif
>  	char name[HSTATE_NAME_LEN];
>  };
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 68c2f2f3c05b7..708103663988a 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -25,6 +25,10 @@ struct hugetlb_cgroup {
>  	 * the counter to account for hugepages from hugetlb.
>  	 */
>  	struct page_counter hugepage[HUGE_MAX_HSTATE];
> +	/*
> +	 * the counter to account for hugepage reservations from hugetlb.
> +	 */
> +	struct page_counter reserved_hugepage[HUGE_MAX_HSTATE];
>  };
>=20
>  #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
> @@ -33,6 +37,15 @@ struct hugetlb_cgroup {
>=20
>  static struct hugetlb_cgroup *root_h_cgroup __read_mostly;
>=20
> +static inline
> +struct page_counter *get_counter(struct hugetlb_cgroup *h_cg, int idx,
> +				 bool reserved)

s/get_/hugetlb_cgroup_get_/ to make it not too generic.
> +{
> +	if (reserved)
> +		return  &h_cg->reserved_hugepage[idx];
> +	return &h_cg->hugepage[idx];
> +}
> +
>  static inline
>  struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_st=
ate *s)
>  {
> @@ -256,28 +269,42 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsi=
gned long nr_pages,
>=20
>  enum {
>  	RES_USAGE,
> +	RES_RESERVATION_USAGE,
>  	RES_LIMIT,
> +	RES_RESERVATION_LIMIT,
>  	RES_MAX_USAGE,
> +	RES_RESERVATION_MAX_USAGE,
>  	RES_FAILCNT,
> +	RES_RESERVATION_FAILCNT,
>  };
>=20
>  static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
>  				   struct cftype *cft)
>  {
>  	struct page_counter *counter;
> +	struct page_counter *reserved_counter;
>  	struct hugetlb_cgroup *h_cg =3D hugetlb_cgroup_from_css(css);
>=20
>  	counter =3D &h_cg->hugepage[MEMFILE_IDX(cft->private)];
> +	reserved_counter =3D &h_cg->reserved_hugepage[MEMFILE_IDX(cft->privat=
e)];
>=20
>  	switch (MEMFILE_ATTR(cft->private)) {
>  	case RES_USAGE:
>  		return (u64)page_counter_read(counter) * PAGE_SIZE;
> +	case RES_RESERVATION_USAGE:
> +		return (u64)page_counter_read(reserved_counter) * PAGE_SIZE;
>  	case RES_LIMIT:
>  		return (u64)counter->max * PAGE_SIZE;
> +	case RES_RESERVATION_LIMIT:
> +		return (u64)reserved_counter->max * PAGE_SIZE;
>  	case RES_MAX_USAGE:
>  		return (u64)counter->watermark * PAGE_SIZE;
> +	case RES_RESERVATION_MAX_USAGE:
> +		return (u64)reserved_counter->watermark * PAGE_SIZE;
>  	case RES_FAILCNT:
>  		return counter->failcnt;
> +	case RES_RESERVATION_FAILCNT:
> +		return reserved_counter->failcnt;
>  	default:
>  		BUG();
>  	}
> @@ -291,6 +318,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_o=
pen_file *of,
>  	int ret, idx;
>  	unsigned long nr_pages;
>  	struct hugetlb_cgroup *h_cg =3D hugetlb_cgroup_from_css(of_css(of));
> +	bool reserved =3D false;
>=20
>  	if (hugetlb_cgroup_is_root(h_cg)) /* Can't set limit on root */
>  		return -EINVAL;
> @@ -303,10 +331,16 @@ static ssize_t hugetlb_cgroup_write(struct kernfs=
_open_file *of,
>  	idx =3D MEMFILE_IDX(of_cft(of)->private);
>  	nr_pages =3D round_down(nr_pages, 1 << huge_page_order(&hstates[idx])=
);
>=20
> +	if (MEMFILE_ATTR(of_cft(of)->private) =3D=3D RES_RESERVATION_LIMIT) {
> +		reserved =3D true;
> +	}
> +
>  	switch (MEMFILE_ATTR(of_cft(of)->private)) {
> +	case RES_RESERVATION_LIMIT:
		reserved =3D true;
		/* fall thru */

>  	case RES_LIMIT:
>  		mutex_lock(&hugetlb_limit_mutex);
> -		ret =3D page_counter_set_max(&h_cg->hugepage[idx], nr_pages);
> +		ret =3D page_counter_set_max(get_counter(h_cg, idx, reserved),
> +					   nr_pages);
>  		mutex_unlock(&hugetlb_limit_mutex);
>  		break;
>  	default:
> @@ -320,18 +354,26 @@ static ssize_t hugetlb_cgroup_reset(struct kernfs=
_open_file *of,
>  				    char *buf, size_t nbytes, loff_t off)
>  {
>  	int ret =3D 0;
> -	struct page_counter *counter;
> +	struct page_counter *counter, *reserved_counter;
>  	struct hugetlb_cgroup *h_cg =3D hugetlb_cgroup_from_css(of_css(of));
>=20
>  	counter =3D &h_cg->hugepage[MEMFILE_IDX(of_cft(of)->private)];
> +	reserved_counter =3D &h_cg->reserved_hugepage[
> +		MEMFILE_IDX(of_cft(of)->private)];
>=20
>  	switch (MEMFILE_ATTR(of_cft(of)->private)) {
>  	case RES_MAX_USAGE:
>  		page_counter_reset_watermark(counter);
>  		break;
> +	case RES_RESERVATION_MAX_USAGE:
> +		page_counter_reset_watermark(reserved_counter);
> +		break;
>  	case RES_FAILCNT:
>  		counter->failcnt =3D 0;
>  		break;
> +	case RES_RESERVATION_FAILCNT:
> +		reserved_counter->failcnt =3D 0;
> +		break;
>  	default:
>  		ret =3D -EINVAL;
>  		break;
> @@ -357,7 +399,7 @@ static void __init __hugetlb_cgroup_file_init(int i=
dx)
>  	struct hstate *h =3D &hstates[idx];
>=20
>  	/* format the size */
> -	mem_fmt(buf, 32, huge_page_size(h));
> +	mem_fmt(buf, sizeof(buf), huge_page_size(h));
>=20
>  	/* Add the limit file */
>  	cft =3D &h->cgroup_files[0];
> @@ -366,28 +408,58 @@ static void __init __hugetlb_cgroup_file_init(int=
 idx)
>  	cft->read_u64 =3D hugetlb_cgroup_read_u64;
>  	cft->write =3D hugetlb_cgroup_write;
>=20
> -	/* Add the usage file */
> +	/* Add the reservation limit file */
>  	cft =3D &h->cgroup_files[1];
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.reservation_limit_in_bytes",
> +		 buf);
> +	cft->private =3D MEMFILE_PRIVATE(idx, RES_RESERVATION_LIMIT);
> +	cft->read_u64 =3D hugetlb_cgroup_read_u64;
> +	cft->write =3D hugetlb_cgroup_write;
> +
> +	/* Add the usage file */
> +	cft =3D &h->cgroup_files[2];
>  	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.usage_in_bytes", buf);
>  	cft->private =3D MEMFILE_PRIVATE(idx, RES_USAGE);
>  	cft->read_u64 =3D hugetlb_cgroup_read_u64;
>=20
> +	/* Add the reservation usage file */
> +	cft =3D &h->cgroup_files[3];
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.reservation_usage_in_bytes",
> +			buf);
> +	cft->private =3D MEMFILE_PRIVATE(idx, RES_RESERVATION_USAGE);
> +	cft->read_u64 =3D hugetlb_cgroup_read_u64;
> +
>  	/* Add the MAX usage file */
> -	cft =3D &h->cgroup_files[2];
> +	cft =3D &h->cgroup_files[4];
>  	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.max_usage_in_bytes", buf);
>  	cft->private =3D MEMFILE_PRIVATE(idx, RES_MAX_USAGE);
>  	cft->write =3D hugetlb_cgroup_reset;
>  	cft->read_u64 =3D hugetlb_cgroup_read_u64;
>=20
> +	/* Add the MAX reservation usage file */
> +	cft =3D &h->cgroup_files[5];
> +	snprintf(cft->name, MAX_CFTYPE_NAME,
> +			"%s.reservation_max_usage_in_bytes", buf);
> +	cft->private =3D MEMFILE_PRIVATE(idx, RES_RESERVATION_MAX_USAGE);
> +	cft->write =3D hugetlb_cgroup_reset;
> +	cft->read_u64 =3D hugetlb_cgroup_read_u64;
> +
>  	/* Add the failcntfile */
> -	cft =3D &h->cgroup_files[3];
> +	cft =3D &h->cgroup_files[6];
>  	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.failcnt", buf);
>  	cft->private  =3D MEMFILE_PRIVATE(idx, RES_FAILCNT);
>  	cft->write =3D hugetlb_cgroup_reset;
>  	cft->read_u64 =3D hugetlb_cgroup_read_u64;
>=20
> +	/* Add the reservation failcntfile */
> +	cft =3D &h->cgroup_files[7];
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.reservation_failcnt", buf);
> +	cft->private  =3D MEMFILE_PRIVATE(idx, RES_FAILCNT);
> +	cft->write =3D hugetlb_cgroup_reset;
> +	cft->read_u64 =3D hugetlb_cgroup_read_u64;
> +
>  	/* NULL terminate the last cft */
> -	cft =3D &h->cgroup_files[4];
> +	cft =3D &h->cgroup_files[8];
>  	memset(cft, 0, sizeof(*cft));

Replace numbers with characters.
>=20
>  	WARN_ON(cgroup_add_legacy_cftypes(&hugetlb_cgrp_subsys,
> --
> 2.23.0.rc1.153.gdeed80330f-goog


