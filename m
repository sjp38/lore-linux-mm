Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD35C43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 15:25:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C192206BA
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 15:25:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C192206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=whu.edu.cn
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D2238E009E; Wed,  9 Jan 2019 10:25:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 181938E0038; Wed,  9 Jan 2019 10:25:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04A878E009E; Wed,  9 Jan 2019 10:25:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B98538E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 10:24:59 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d3so4313606pgv.23
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 07:24:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :references:in-reply-to:subject:date:message-id:mime-version
         :content-transfer-encoding:thread-index:content-language;
        bh=3LKxE6zAvs+nYtuCq90r+nGTFMn9Pph1/xm+joxpk8o=;
        b=rmasLJyGsiStH3YSRax7Kqdcl268KEn/CjQXaXWmuGefza/RUc/xfJcur7o9xJ26is
         icGuVFFlsjHjpA4fxX+ro8Nwrf6K3uH+hKsThNvzVhbbRmolSrLTuUV18slAqudB+J2M
         2D8Nt9RjlL9X7wFA9Qjs8pzZFdRIodNNmNeQqOldfYyKuKfAKPny9jTjIWbvM86/33gb
         LTqwMo8kLAfxDCctqjnJwyPCGH0SVKawixoQLgvjsMtV4bwwDpKFBTWyXYEEdhhXQfqZ
         k/CY+gT3djMwxQvEAzw2UwZnfLihB3Lt1kdDuofkbL6AolWdit92UWHaWVOkDhMtPQyh
         +LRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rocking@whu.edu.cn designates 159.65.134.6 as permitted sender) smtp.mailfrom=rocking@whu.edu.cn
X-Gm-Message-State: AJcUukdAIqPuniROOrJ1cNkgVi59qnZKpYqd8dwZS2h7ZKG9Og3YaBAE
	jqs8syiQ0RYKvYc1HPr/WqgjKVKQbJJtmIdUXfai/8SrNljDlIfI6DJEBYd8ywdS+UMwI0FDYcX
	VPglniMnPL95P0Tcs6pSXHdljUZEN1d7UYFfuC7CHcq5cd+6rRbiL02+lohvKaajR3g==
X-Received: by 2002:a63:658:: with SMTP id 85mr5726855pgg.373.1547047499446;
        Wed, 09 Jan 2019 07:24:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4MefKahGGqbilqnjIb1UPChqE2sMRbYkRj/XKsBZ9SONP4vNb3Vwx6L3D8KVRiM2RYvlAl
X-Received: by 2002:a63:658:: with SMTP id 85mr5726817pgg.373.1547047498728;
        Wed, 09 Jan 2019 07:24:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547047498; cv=none;
        d=google.com; s=arc-20160816;
        b=sLTBEy3evpSKYVtXbCZY6WmHfDgizILh37wmdylHigSI31hqYDeR/BJGVOUGtaZ0wB
         qspnn/ueWbEGtJ/pqqaUCbrkxwN5ADYaZM8fugjmkJyr/aF/jJ+tEn/gJUv/2fkwsOBT
         BwVqcsD1gl1hR43rgfiv5pc5TZlYEcalem7IS1AMpIqAPZI4Giv6LCxTKl+YcgVHFt7V
         HZAH1vC2lymd3fl9VeLeDQ75QMxYrOyO464hUgkRDxJTHx/7ugMMKhggLvrvrgYzQbl3
         rEAy+T3HwIJqNk9bOTLyFnAwAL29wy8MAVbuN7NAzctud0FVjdwFzaUceE9cGbdQxns6
         SR9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:thread-index:content-transfer-encoding
         :mime-version:message-id:date:subject:in-reply-to:references:cc:to
         :from;
        bh=3LKxE6zAvs+nYtuCq90r+nGTFMn9Pph1/xm+joxpk8o=;
        b=w1fIrw073RXNlj6o4zlAsrH2M2mvhn53nBGIP2AETttZjb6MLk1i+570DusEktf7rk
         NeUm9VYdIH/Z0kTbdEeEmCiYQ8xlgzJQ6WRt8gMEzrjCuhwmiTTV1jlAbjWQ9ysismmI
         2rGReh+vt7LF4x+l9+A4TxEgbxb3uKN7AewEYyhrJYhnie7TdrmFYavI/TrjvVcF1YSM
         VL2i7sFwfRfv+HHirUTWEy/UH8QAQ0xX9qEI2MGPQh+4B9fZHzEX/Ye2ZEzuaHHH+RwI
         NIpxGo6HUNFYYdqBZQrBpDCCpnUVoYldJS4LZc6wMbLN9U8fYgpEk4qtmTxXWkWT5i10
         FLMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rocking@whu.edu.cn designates 159.65.134.6 as permitted sender) smtp.mailfrom=rocking@whu.edu.cn
Received: from zg8tmtu5ljy1ljeznc42.icoremail.net (zg8tmtu5ljy1ljeznc42.icoremail.net. [159.65.134.6])
        by mx.google.com with SMTP id i16si66128209pgk.445.2019.01.09.07.24.58
        for <linux-mm@kvack.org>;
        Wed, 09 Jan 2019 07:24:58 -0800 (PST)
Received-SPF: pass (google.com: domain of rocking@whu.edu.cn designates 159.65.134.6 as permitted sender) client-ip=159.65.134.6;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rocking@whu.edu.cn designates 159.65.134.6 as permitted sender) smtp.mailfrom=rocking@whu.edu.cn
Received: from MI20170214RZUL (unknown [114.255.247.135])
	by email2 (Coremail) with SMTP id AgBjCgDX3zc8EjZcB5YRCg--.43451S3;
	Wed, 09 Jan 2019 23:24:47 +0800 (CST)
From: "Peng Wang" <rocking@whu.edu.cn>
To: "'Matthew Wilcox'" <willy@infradead.org>
Cc: <cl@linux.com>,
	<penberg@kernel.org>,
	<rientjes@google.com>,
	<iamjoonsoo.kim@lge.com>,
	<akpm@linux-foundation.org>,
	<linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
References: <20190109090628.1695-1-rocking@whu.edu.cn> <20190109121352.GI6310@bombadil.infradead.org>
In-Reply-To: <20190109121352.GI6310@bombadil.infradead.org>
Subject: RE: [PATCH] mm/slub.c: re-randomize random_seq if necessary
Date: Wed, 9 Jan 2019 23:24:44 +0800
Message-ID: <000501d4a82f$74821b40$5d8651c0$@whu.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Outlook 16.0
Thread-Index: AQHS10gH9bp1oZXRh7a3ROcd3vd+NwIerMmLpZmMotA=
Content-Language: zh-cn
X-CM-TRANSID:AgBjCgDX3zc8EjZcB5YRCg--.43451S3
X-Coremail-Antispam: 1UD129KBjvdXoWrurW5tr4rCr4fCw15Zw43KFg_yoWDGrg_Za
	4IvFyDAa15Wr4DWa45Ca15ZryxKr9ruF18t34kGr12qryvqrZrA3W5W34xu3WIvFn8GrW3
	Ar4kJa1xAasakjkaLaAFLSUrUUUUUb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUIcSsGvfJTRUUUb2xYjsxI4VWxJwAYFVCjjxCrM7AC8VAFwI0_Gr0_Xr1l1xkIjI8I
	6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l1IIY67AEw4v_Jr0_Jr4l8cAvFVAK0II2c7xJM2
	8CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW7JVWDJwA2z4x0Y4vE2Ix0
	cI8IcVCY1x0267AKxVWxJVW8Jr1l84ACjcxK6I8E87Iv67AKxVW0oVCq3wA2z4x0Y4vEx4
	A2jsIEc7CjxVAFwI0_GcCE3s1le2I262IYc4CY6c8Ij28IcVAaY2xG8wAqx4xG64xvF2IE
	w4CE5I8CrVC2j2WlYx0E2Ix0cI8IcVAFwI0_Jr0_Jr4lYx0Ex4A2jsIE14v26r1j6r4UMc
	vjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwCY02Avz4vE14v_XrWl42xK82IY
	c2Ij64vIr41l4I8I3I0E4IkC6x0Yz7v_Jr0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s
	026x8GjcxK67AKxVWUGVWUWwC2zVAF1VAY17CE14v26r1q6r43MIIYrxkI7VAKI48JMIIF
	0xvE2Ix0cI8IcVAFwI0_Jr0_JF4lIxAIcVC0I7IYx2IY6xkF7I0E14v26r1j6r4UMIIF0x
	vE42xK8VAvwI8IcIk0rVWrJr0_WFyUJwCI42IY6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E
	87Iv6xkF7I0E14v26r4j6r4UJbIYCTnIWIevJa73UjIFyTuYvjxU4znQUUUUU
X-CM-SenderInfo: qsqrijaqrviiqqxyq4lkxovvfxof0/
X-Bogosity: Ham, tests=bogofilter, spamicity=0.004773, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109152444.RLNtgft24Zf4QvzLP7eYXdIUXuYx8Cv5epW8Xm3tOQ0@z>


On Wednesday, January 9, 2019 8:14 PM, Matthew Wilcox wrote:
> On Wed, Jan 09, 2019 at 05:06:27PM +0800, Peng Wang wrote:
> > calculate_sizes() could be called in several places
> > like (red_zone/poison/order/store_user)_store() while
> > random_seq remains unchanged.
> >
> > If random_seq is not NULL in calculate_sizes(), re-randomize it.
> 
> Why do we want to re-randomise the slab at these points?

At these points, s->size might change,
but random_seq still use the old size and not updated.

When doing shuffle_freelist() in allocat_slab(),
old next object offset would be used. 

    idx = s->random_seq[*pos];

One possible case:

s->size gets smaller, then number of objects in a slab gets bigger.
The size of s->random_seq array should be bigger but not updated.
In next_freelist_entry(), *pos might exceed the s->random_seq.

When we get zero value from s->random_seq[*pos] twice after exceeding,
BUG_ON(object == fp) would be triggered in set_freepointer().


