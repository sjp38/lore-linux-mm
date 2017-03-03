Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 390A66B0389
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 13:41:30 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id f191so105636980qka.7
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 10:41:30 -0800 (PST)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com. [209.85.220.176])
        by mx.google.com with ESMTPS id d13si9935135qkb.262.2017.03.03.10.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 10:41:29 -0800 (PST)
Received: by mail-qk0-f176.google.com with SMTP id g129so6737403qkd.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 10:41:29 -0800 (PST)
Subject: Re: [RFC PATCH 03/12] staging: android: ion: Duplicate sg_table
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-4-git-send-email-labbott@redhat.com>
 <07df01d293f6$bcfb4f30$36f1ed90$@alibaba-inc.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <59f69b1b-0a10-01e9-3e64-387d8f123674@redhat.com>
Date: Fri, 3 Mar 2017 10:41:25 -0800
MIME-Version: 1.0
In-Reply-To: <07df01d293f6$bcfb4f30$36f1ed90$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Sumit Semwal' <sumit.semwal@linaro.org>, 'Riley Andrews' <riandrews@android.com>, arve@android.com
Cc: romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, 'Brian Starkey' <brian.starkey@arm.com>, 'Daniel Vetter' <daniel.vetter@intel.com>, 'Mark Brown' <broonie@kernel.org>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>, linux-mm@kvack.org

On 03/03/2017 12:18 AM, Hillf Danton wrote:
> 
> On March 03, 2017 5:45 AM Laura Abbott wrote: 
>>
>> +static struct sg_table *dup_sg_table(struct sg_table *table)
>> +{
>> +	struct sg_table *new_table;
>> +	int ret, i;
>> +	struct scatterlist *sg, *new_sg;
>> +
>> +	new_table = kzalloc(sizeof(*new_table), GFP_KERNEL);
>> +	if (!new_table)
>> +		return ERR_PTR(-ENOMEM);
>> +
>> +	ret = sg_alloc_table(new_table, table->nents, GFP_KERNEL);
>> +	if (ret) {
>> +		kfree(table);
> 
> Free new table?
> 
>> +		return ERR_PTR(-ENOMEM);
>> +	}
>> +
>> +	new_sg = new_table->sgl;
>> +	for_each_sg(table->sgl, sg, table->nents, i) {
>> +		memcpy(new_sg, sg, sizeof(*sg));
>> +		sg->dma_address = 0;
>> +		new_sg = sg_next(new_sg);
>> +	}
>> +
> 
> Do we need a helper, sg_copy_table(dst_table, src_table)?
> 
>> +	return new_table;
>> +}
>> +

Yes, that would probably be good since I've seen this
code elsewhere.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
