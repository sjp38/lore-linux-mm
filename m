Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7B9AC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 09:28:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8302B22CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 09:28:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8302B22CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 162BB6B0003; Tue,  3 Sep 2019 05:28:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EBCC6B0005; Tue,  3 Sep 2019 05:28:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0011D6B0006; Tue,  3 Sep 2019 05:28:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id CDA9C6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 05:28:30 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6BC5C824CA25
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 09:28:30 +0000 (UTC)
X-FDA: 75893083980.05.wheel09_846f1425aec28
X-HE-Tag: wheel09_846f1425aec28
X-Filterd-Recvd-Size: 3149
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 09:28:29 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EEB05AD17;
	Tue,  3 Sep 2019 09:28:27 +0000 (UTC)
Date: Tue, 3 Sep 2019 11:28:27 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Honglei Wang <honglei.wang@oracle.com>
Cc: linux-mm@kvack.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org
Subject: Re: [PATCH] mm/vmscan: get number of pages on the LRU list in
 memcgroup base on lru_zone_size
Message-ID: <20190903092827.GP14028@dhcp22.suse.cz>
References: <20190903085416.12059-1-honglei.wang@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903085416.12059-1-honglei.wang@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 03-09-19 16:54:16, Honglei Wang wrote:
> lruvec_lru_size() is involving lruvec_page_state_local() to get the
> lru_size in the current code. It's base on lruvec_stat_local.count[]
> of mem_cgroup_per_node. This counter is updated in batch. It won't
> do charge if the number of coming pages doesn't meet the needs of
> MEMCG_CHARGE_BATCH who's defined as 32 now.
> 
> This causes small section of memory can't be handled as expected in
> some scenario. For example, if we have only 32 pages madvise free
> memory in memcgroup, these pages won't be freed as expected when it
> meets memory pressure in this group.

Could you be more specific please?

> Getting lru_size base on lru_zone_size of mem_cgroup_per_node which
> is not updated in batch can make this a bit more accurate.

This is effectivelly reverting 1a61ab8038e72. There were no numbers
backing that commit, neither this one has. The only hot path I can see
is workingset_refault. All others seems to be in the reclaim path.
 
> Signed-off-by: Honglei Wang <honglei.wang@oracle.com>

That being said, I am not against this patch but the changelog should be
more specific about the particular problem and how serious it is.

> ---
>  mm/vmscan.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c77d1e3761a7..c28672460868 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -354,12 +354,13 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
>   */
>  unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx)
>  {
> -	unsigned long lru_size;
> +	unsigned long lru_size = 0;
>  	int zid;
>  
> -	if (!mem_cgroup_disabled())
> -		lru_size = lruvec_page_state_local(lruvec, NR_LRU_BASE + lru);
> -	else
> +	if (!mem_cgroup_disabled()) {
> +		for (zid = 0; zid < MAX_NR_ZONES; zid++)
> +			lru_size += mem_cgroup_get_zone_lru_size(lruvec, lru, zid);
> +	} else
>  		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
>  
>  	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
> -- 
> 2.17.0

-- 
Michal Hocko
SUSE Labs

