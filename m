Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 087E3C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:45:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AED0921743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:45:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="pKGERV63"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AED0921743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CDD06B0007; Wed, 17 Jul 2019 14:45:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47D9C8E0003; Wed, 17 Jul 2019 14:45:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31E9D8E0001; Wed, 17 Jul 2019 14:45:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 098F96B0007
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:45:17 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id 186so9842300oid.17
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 11:45:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=h7UHqDmF8opBtyW4k2R9DOYcnvPewTaVGrEEHVnBDOI=;
        b=it86xx83CdzFv3DwmZFoH6fztcuvBJps3+96vcIYBueX8ygGQ2HOBXBR+uCKKbIBun
         yPH1+FiYbng1Q9xKSU423DO/Ojy1jt7LVtuCF28TKxRLaKfpDCWQkVsad3wXgrqedseB
         vgmWe2DIK8fVRHsnuoPeEw6rmI+qmWFGH2imN/0JNG60QeYe3CnP68Y+7fbor/kMjECA
         4e/DpCczE7Spnnr35YW9bpXLY0KBW4zlhd+HD2+ZuKvvt/hXI873vgYMe0czAjRWAMmd
         ESA8jRPtbzC0yQzMFuAAouT4VYKstLP59sxyFy6wJhbIKW27rtbKxlxZiEQNwjUnqqpX
         ShuA==
X-Gm-Message-State: APjAAAUM0Gqwq5LcwUaOPbys/UFL3+Ps3K2s7Xw8wPFL72KoVa/3oQw6
	Wy7aI3bAYMZv2+KSDaXvITIrvj5WAV/iwd96XQad2t4//9tNHStf3J/6zLcxugovA1tED2tkPnZ
	yMDgU/Dz34ztMlacOZ+g6X85tWVD16LzKAfTphz8/JMg3HtN3H5RbJYWq0f19YqBRHQ==
X-Received: by 2002:a05:6830:12d6:: with SMTP id a22mr2749290otq.236.1563389116705;
        Wed, 17 Jul 2019 11:45:16 -0700 (PDT)
X-Received: by 2002:a05:6830:12d6:: with SMTP id a22mr2749262otq.236.1563389116113;
        Wed, 17 Jul 2019 11:45:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563389116; cv=none;
        d=google.com; s=arc-20160816;
        b=k1AollhXk/ulwXTlLInQXeeERam6YhK0FETZpE8M+mc406RWxQWoxRFmN44S0UuYK/
         M9D22fIr8heoRIAHCFDGzSXLohcAWLV50Y5ERyXha0NA9a11mjhhPiRTFPjhsFJsr0eS
         d2NlfWtBeL0LTienUMsPbYP2GXjcr0igHQt+OOFH2wQPH19QJiylG1TcPVDS5x1NJQUF
         GqHqs98yBlYgWYoRQeSZ15kNgo4sLP3wYiqKHUZTwW1Qx0jqLJVi6SWl38Ma3GvNxvUp
         dcHWAXNWZ+/n24Lsb2EplCyLpzrNyPmzfQDMJegcTNKXUlIPDOyTx7Ni6LKufqvzwbZJ
         hnvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=h7UHqDmF8opBtyW4k2R9DOYcnvPewTaVGrEEHVnBDOI=;
        b=rMfZCU34/E58trzmpS43xhNM7ZwUqLjj089N+xWdI0cC1a4SdeVIha7S0Qg+CZSYWR
         z+/2etHojCcQVytDleeKj9LkFSISjJ8FsX40xZsssBb04MaHwHa2xj+G5Nd2wckXeO9N
         o7DHE0UU7xUrDL7I2jxruttGwjIxcjGiN/w5d37PTB5TyRIiZzOXXTtg8E9cNsWKUSsF
         Hb+J7a8Pn6OVPRtlbFog/BRtwh+xQtX8Q0K9Ld+9jwuJH67nCjlpRLRKeLtIofyWC/jQ
         32oI7Y2k8ilf9lOZyDV/u9jGtfHKRqgqFvuIZJSCTiywr6u2keBuZ2aypPRhDAzi1yAd
         LRcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=pKGERV63;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor12698583otk.47.2019.07.17.11.45.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 11:45:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=pKGERV63;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=h7UHqDmF8opBtyW4k2R9DOYcnvPewTaVGrEEHVnBDOI=;
        b=pKGERV63xKtGcHMecfB9++5NqX4RRPqpXfwrB1LYaGmwWI9xErk2KUs8GsManNErl8
         2jOG2qGjwODrwh7FuSERmM4mpEoUvixORQnIzHoMePnr3m/D4wT5J1mIjMRQPeU+X+71
         Lohytrnp3+OSmeuVRRQ+kN+7ak4aVG3AjdRlgycS9P7xt0iwd/2YlI9d5zrkmsWf1UKQ
         nMPE9pGf/0M23t+Q85VYLbgDD0gwxLFZ0Co0uOCY8oa9UiNZt19tT9Rwd78RkqLJwLyO
         7ScyRAhWwcq05qEulSoQf3h2CkdJORFNZOzPll+QXm9V3QVrbIR6BseNhSGf6eEeOU/t
         K7Vw==
X-Google-Smtp-Source: APXvYqy4sNd+44vuqYPh3QAndY5bf6BMKciMXtUL7SOZKPc+qYGwBiIEPN03YW/ziTemzeRtyNF2cYyFBRtb3LrwNgY=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr22177888otn.247.1563389115753;
 Wed, 17 Jul 2019 11:45:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190717090725.23618-1-osalvador@suse.de> <20190717090725.23618-3-osalvador@suse.de>
In-Reply-To: <20190717090725.23618-3-osalvador@suse.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Jul 2019 11:45:05 -0700
Message-ID: <CAPcyv4gxhjNmy=8e0MiB88LO5oWPmAPL-gnkG-jF5LpKn1E4vA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Michal Hocko <mhocko@suse.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 2:07 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> Since [1], shrink_{zone,node}_span work on PAGES_PER_SUBSECTION granularity.
> We need to adapt the loop that checks whether a zone/node contains only holes,
> and skip the whole range to be removed.
>
> Otherwise, since sub-sections belonging to the range to be removed have not yet
> been deactivated, pfn_valid() will return true on those and we will be left
> with a wrong accounting of spanned_pages, both for the zone and the node.
>
> Fixes: mmotm ("mm/hotplug: prepare shrink_{zone, pgdat}_span for sub-section removal")
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

