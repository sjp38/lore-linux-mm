Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8BA5C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 13:31:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B28E20644
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 13:31:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B28E20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4747E6B0006; Mon,  5 Aug 2019 09:31:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 424BD6B0007; Mon,  5 Aug 2019 09:31:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3141B6B0008; Mon,  5 Aug 2019 09:31:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D607E6B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 09:31:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so51600309edw.20
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 06:31:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ShBgVtpwp30olNzWLd8zAsYWuUGiRG22aEjjNI7xOCY=;
        b=fL8T3eMOIj2HzGZi2zFXIT1MtqBYACe9kPxSZ2UMOvf86fJFUDS+bDsonEA3I7MYOr
         V/1m2unFS6zgBu2h/WcABRHXLbZCLNe1teSEMzX6fzGoNRHvtzRqLs6PwGHFoND0jIm1
         O4AltiG19yvVJwfYaqlSY/3SQ1BATUEIMZ+GCWoBxWrbpWrORfKK7AHEdi/C1vtX4jIl
         wOb2c7Q2VM7fqfm5a6gXEjkiMuAYIA1rPGCCTQjCX87hQrMJqjI4+Rw2YAqei7cEaxRl
         jnL3+YZkWqO5xSj37dK48Kn4o30TelPeKcQK6uu1/P8jOeNtvIDsoaQAd1uHIgUH4/xY
         LP7Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXol2cY0DMuQgX6WpQeBeOFSgTgQpu50VjLxDHy869OPJYZwQM/
	uYlLkdbxo0FNZ4PNwsubJurCoQgu6DVtwx2IKo+3rXPJFZ+5NMAjzdgLmhXA75sK9KvMr+XEx0P
	uz3ldavkc8yKs77A49ww03/rriBlf2gPiX4HD07ba/jTYlRrucL9BBd2vmWcuimA=
X-Received: by 2002:a50:fa05:: with SMTP id b5mr131487856edq.269.1565011882423;
        Mon, 05 Aug 2019 06:31:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIPXq78hotc6J3ha13tBYN1hK9MqCqGVVQvIGs7NAzf0InJVqAdIJDmD2Z3/+MLm+7fSiD
X-Received: by 2002:a50:fa05:: with SMTP id b5mr131487757edq.269.1565011881386;
        Mon, 05 Aug 2019 06:31:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565011881; cv=none;
        d=google.com; s=arc-20160816;
        b=rqn2sn/1/P5wyLpTwIKxPP+6AS6hn911y4UlfRv/wsN2VZjDacPEieEtY+PzGSWEFT
         TeDdHhd1PXRBZ0tusDSKDnQ7+MWRD85oOq2SA//OL1U84oYtKTrX4xN0kUuetACAEVTM
         ZvYIE/uSKClG7WeuEeMRmRUrgD50qtfRBFGVVYSkmn0FGOJBWyw0GOBMGY9FzzkbtG9h
         oKrvtYGKIKotYJOhN9aHu+K1pphp34uZTKMJKBNQmqD6ajLxHMTtIAJLityGR7DZksmc
         gGUZmmc1ud5WbH4RfAiXNiJU3hASRkcnDnTUrGS/vnLgDru4bB+t6EG17UVgAkFLe3ix
         tuVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ShBgVtpwp30olNzWLd8zAsYWuUGiRG22aEjjNI7xOCY=;
        b=Sa7hRilVhHjWfPgu7gbh01fLi6ixI/2RxKbyrDVb57JcQVkNcsiY59vTj37oFgcu/D
         8FSx2qvANmLX4lhN+9r9eCNR+V7Fxh+AvOmAw46U/BhFflwiF4yMjYbG/FBAqjZYmNqu
         G+HT+z63SIF2tknn8cxi5TEU6ftKZ49nnMfnRf34bjcRt6+ON/khNDHpYpKeZXtunE+w
         FcFvK3DvTBkDP8+iPc10fZpoJ275p0OqQaeZIsxsCzd6jza/XG4AEUACHBWgns+DfGey
         Bs1sAOiyPByaHrqKH59GjAvLwCNCy5JFfr9rjtpcwkCXyaGm5ELh03PAOTnOzuO6/hk5
         uTzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c22si31481292eda.76.2019.08.05.06.31.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 06:31:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AEAF1ACB4;
	Mon,  5 Aug 2019 13:31:20 +0000 (UTC)
Date: Mon, 5 Aug 2019 15:31:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Artem S. Tashkinov" <aros@gmx.com>, linux-kernel@vger.kernel.org,
	linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Suren Baghdasaryan <surenb@google.com>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190805133119.GO7597@dhcp22.suse.cz>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 14:13:16, Vlastimil Babka wrote:
> On 8/4/19 11:23 AM, Artem S. Tashkinov wrote:
> > Hello,
> > 
> > There's this bug which has been bugging many people for many years
> > already and which is reproducible in less than a few minutes under the
> > latest and greatest kernel, 5.2.6. All the kernel parameters are set to
> > defaults.
> > 
> > Steps to reproduce:
> > 
> > 1) Boot with mem=4G
> > 2) Disable swap to make everything faster (sudo swapoff -a)
> > 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
> > 4) Start opening tabs in either of them and watch your free RAM decrease
> > 
> > Once you hit a situation when opening a new tab requires more RAM than
> > is currently available, the system will stall hard. You will barely  be
> > able to move the mouse pointer. Your disk LED will be flashing
> > incessantly (I'm not entirely sure why). You will not be able to run new
> > applications or close currently running ones.
> 
> > This little crisis may continue for minutes or even longer. I think
> > that's not how the system should behave in this situation. I believe
> > something must be done about that to avoid this stall.
> 
> Yeah that's a known problem, made worse SSD's in fact, as they are able
> to keep refaulting the last remaining file pages fast enough, so there
> is still apparent progress in reclaim and OOM doesn't kick in.
> 
> At this point, the likely solution will be probably based on pressure
> stall monitoring (PSI). I don't know how far we are from a built-in
> monitor with reasonable defaults for a desktop workload, so CCing
> relevant folks.

Another potential approach would be to consider the refault information
we have already for file backed pages. Once we start reclaiming only
workingset pages then we should be trashing, right? It cannot be as
precise as the cost model which can be defined around PSI but it might
give us at least a fallback measure.

This is a really just an idea for a primitive detection. Most likely
incorrect one but it shows an idea at least. It is completely untested
and might be completely broken so unless somebody is really brave and
doesn't run anything that would be missed then I do not recommend to run
it.

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394cabaf4e..7f30c78b4fbc 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -300,6 +300,7 @@ struct lruvec {
 	atomic_long_t			inactive_age;
 	/* Refaults at the time of last reclaim cycle */
 	unsigned long			refaults;
+	atomic_t			workingset_refaults;
 #ifdef CONFIG_MEMCG
 	struct pglist_data *pgdat;
 #endif
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bfb5c4ac108..4401753c3912 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -311,6 +311,15 @@ void *workingset_eviction(struct page *page);
 void workingset_refault(struct page *page, void *shadow);
 void workingset_activation(struct page *page);
 
+bool lruvec_trashing(struct lruvec *lruvec)
+{
+	/*
+	 * One quarter of the inactive list is constantly refaulting.
+	 * This suggests that we are trashing.
+	 */
+	return 4 * atomic_read(&lruvec->workingset_refaults) > lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES);
+}
+
 /* Only track the nodes of mappings with shadow entries */
 void workingset_update_node(struct xa_node *node);
 #define mapping_set_update(xas, mapping) do {				\
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7889f583ced9..d198594af0cd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2381,6 +2381,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 						  denominator);
 			break;
 		case SCAN_FILE:
+			if (lruvec_trashing(lruvec)) {
+				size = 0;
+				scan = 0;
+				break;
+			}
 		case SCAN_ANON:
 			/* Scan one type exclusively */
 			if ((scan_balance == SCAN_FILE) != file) {
diff --git a/mm/workingset.c b/mm/workingset.c
index e0b4edcb88c8..ee4c45b27e34 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -309,17 +309,25 @@ void workingset_refault(struct page *page, void *shadow)
 	 * don't act on pages that couldn't stay resident even if all
 	 * the memory was available to the page cache.
 	 */
-	if (refault_distance > active_file)
+	if (refault_distance > active_file) {
+		atomic_set(&lruvec->workingset_refaults, 0);
 		goto out;
+	}
 
 	SetPageActive(page);
 	atomic_long_inc(&lruvec->inactive_age);
 	inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
+	atomic_inc(&lruvec->workingset_refaults);
 
 	/* Page was active prior to eviction */
 	if (workingset) {
 		SetPageWorkingset(page);
 		inc_lruvec_state(lruvec, WORKINGSET_RESTORE);
+		/*
+		 * Double the trashing numbers for the actual working set.
+		 * refaults
+		 */
+		atomic_inc(&lruvec->workingset_refaults);
 	}
 out:
 	rcu_read_unlock();
-- 
Michal Hocko
SUSE Labs

