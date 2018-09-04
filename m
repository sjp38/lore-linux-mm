Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1024D6B6C6E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 03:57:13 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i188-v6so2853463itf.6
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 00:57:13 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y204-v6si16569197ioy.120.2018.09.04.00.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 00:57:12 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [RFC][PATCH 3/5] [PATCH 3/5] kvm-ept-idle: HVA indexed EPT read
From: Nikita Leshenko <nikita.leshchenko@oracle.com>
In-Reply-To: <20180901124811.591511876@intel.com>
Date: Tue, 4 Sep 2018 09:57:01 +0200
Content-Transfer-Encoding: 7bit
Message-Id: <37B30FD3-7955-4C0B-AAB5-544359F4D157@oracle.com>
References: <20180901112818.126790961@intel.com>
 <20180901124811.591511876@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 1 Sep 2018, at 13:28, Fengguang Wu <fengguang.wu@intel.com> wrote:
> +static ssize_t ept_idle_read(struct file *file, char *buf,
> +			     size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task = file->private_data;
> +	struct ept_idle_ctrl *eic;
> +	unsigned long hva_start = *ppos << BITMAP_BYTE2PVA_SHIFT;
> +	unsigned long hva_end = hva_start + (count << BITMAP_BYTE2PVA_SHIFT);
> +	int ret;
> +
> +	if (*ppos % IDLE_BITMAP_CHUNK_SIZE ||
> +	    count % IDLE_BITMAP_CHUNK_SIZE)
> +		return -EINVAL;
> +
> +	eic = kzalloc(sizeof(*eic), GFP_KERNEL);
> +	if (!eic)
> +		return -EBUSY;
> +
> +	eic->buf = buf;
> +	eic->buf_size = count;
> +	eic->kvm = task_kvm(task);
> +	if (!eic->kvm) {
> +		ret = -EINVAL;
> +		goto out_free;
> +	}
I think you need to increment the refcount while using kvm,
otherwise kvm can be destroyed from another thread while you're
walking it.

-Nikita
> +
> +	ret = ept_idle_walk_hva_range(eic, hva_start, hva_end);
> +	if (ret)
> +		goto out_free;
> +
> +	ret = eic->bytes_copied;
> +	*ppos += ret;
> +out_free:
> +	kfree(eic);
> +
> +	return ret;
> +}
