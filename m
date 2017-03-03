Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B166F6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 03:18:38 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id l66so1339187pfl.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 00:18:38 -0800 (PST)
Received: from out0-152.mail.aliyun.com (out0-152.mail.aliyun.com. [140.205.0.152])
        by mx.google.com with ESMTP id c2si9890628plb.50.2017.03.03.00.18.37
        for <linux-mm@kvack.org>;
        Fri, 03 Mar 2017 00:18:37 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com> <1488491084-17252-4-git-send-email-labbott@redhat.com>
In-Reply-To: <1488491084-17252-4-git-send-email-labbott@redhat.com>
Subject: Re: [RFC PATCH 03/12] staging: android: ion: Duplicate sg_table
Date: Fri, 03 Mar 2017 16:18:27 +0800
Message-ID: <07df01d293f6$bcfb4f30$36f1ed90$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Laura Abbott' <labbott@redhat.com>, 'Sumit Semwal' <sumit.semwal@linaro.org>, 'Riley Andrews' <riandrews@android.com>, arve@android.com
Cc: romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, 'Brian Starkey' <brian.starkey@arm.com>, 'Daniel Vetter' <daniel.vetter@intel.com>, 'Mark Brown' <broonie@kernel.org>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>, linux-mm@kvack.org


On March 03, 2017 5:45 AM Laura Abbott wrote: 
> 
> +static struct sg_table *dup_sg_table(struct sg_table *table)
> +{
> +	struct sg_table *new_table;
> +	int ret, i;
> +	struct scatterlist *sg, *new_sg;
> +
> +	new_table = kzalloc(sizeof(*new_table), GFP_KERNEL);
> +	if (!new_table)
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = sg_alloc_table(new_table, table->nents, GFP_KERNEL);
> +	if (ret) {
> +		kfree(table);

Free new table?

> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	new_sg = new_table->sgl;
> +	for_each_sg(table->sgl, sg, table->nents, i) {
> +		memcpy(new_sg, sg, sizeof(*sg));
> +		sg->dma_address = 0;
> +		new_sg = sg_next(new_sg);
> +	}
> +

Do we need a helper, sg_copy_table(dst_table, src_table)?

> +	return new_table;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
