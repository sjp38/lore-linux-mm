Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E18B6B6C82
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 04:15:15 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e15-v6so1622309pfi.5
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 01:15:15 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id g10-v6si18690506pgl.425.2018.09.04.01.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 01:15:14 -0700 (PDT)
Date: Tue, 4 Sep 2018 16:15:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 3/5] [PATCH 3/5] kvm-ept-idle: HVA indexed EPT read
Message-ID: <20180904081505.4vu4rx6ksdnp5nk4@wfg-t540p.sh.intel.com>
References: <20180901112818.126790961@intel.com>
 <20180901124811.591511876@intel.com>
 <37B30FD3-7955-4C0B-AAB5-544359F4D157@oracle.com>
 <5249147EF0246348BBCB3713DC3757BF8D0D0C@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <5249147EF0246348BBCB3713DC3757BF8D0D0C@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Peng, DongX" <dongx.peng@intel.com>
Cc: Nikita Leshenko <nikita.leshchenko@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "Liu, Jingqi" <jingqi.liu@intel.com>, "Dong, Eddie" <eddie.dong@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Yeah thanks! Currently we are restructuring the related functions,
will add these calls when sorted out the walk order and hole issues.

Thanks,
Fengguang

On Tue, Sep 04, 2018 at 04:12:00PM +0800, Peng Dong wrote:
>kvm_get_kvm() kvm_put_kvm()
>
>-----Original Message-----
>From: Nikita Leshenko [mailto:nikita.leshchenko@oracle.com]
>Sent: Tuesday, September 4, 2018 3:57 PM
>To: Wu, Fengguang <fengguang.wu@intel.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>; Linux Memory Management List <linux-mm@kvack.org>; Peng, DongX <dongx.peng@intel.com>; Liu, Jingqi <jingqi.liu@intel.com>; Dong, Eddie <eddie.dong@intel.com>; Hansen, Dave <dave.hansen@intel.com>; Huang, Ying <ying.huang@intel.com>; Brendan Gregg <bgregg@netflix.com>; kvm@vger.kernel.org; LKML <linux-kernel@vger.kernel.org>
>Subject: Re: [RFC][PATCH 3/5] [PATCH 3/5] kvm-ept-idle: HVA indexed EPT read
>
>On 1 Sep 2018, at 13:28, Fengguang Wu <fengguang.wu@intel.com> wrote:
>> +static ssize_t ept_idle_read(struct file *file, char *buf,
>> +			     size_t count, loff_t *ppos)
>> +{
>> +	struct task_struct *task = file->private_data;
>> +	struct ept_idle_ctrl *eic;
>> +	unsigned long hva_start = *ppos << BITMAP_BYTE2PVA_SHIFT;
>> +	unsigned long hva_end = hva_start + (count << BITMAP_BYTE2PVA_SHIFT);
>> +	int ret;
>> +
>> +	if (*ppos % IDLE_BITMAP_CHUNK_SIZE ||
>> +	    count % IDLE_BITMAP_CHUNK_SIZE)
>> +		return -EINVAL;
>> +
>> +	eic = kzalloc(sizeof(*eic), GFP_KERNEL);
>> +	if (!eic)
>> +		return -EBUSY;
>> +
>> +	eic->buf = buf;
>> +	eic->buf_size = count;
>> +	eic->kvm = task_kvm(task);
>> +	if (!eic->kvm) {
>> +		ret = -EINVAL;
>> +		goto out_free;
>> +	}
>I think you need to increment the refcount while using kvm, otherwise kvm can be destroyed from another thread while you're walking it.
>
>-Nikita
>> +
>> +	ret = ept_idle_walk_hva_range(eic, hva_start, hva_end);
>> +	if (ret)
>> +		goto out_free;
>> +
>> +	ret = eic->bytes_copied;
>> +	*ppos += ret;
>> +out_free:
>> +	kfree(eic);
>> +
>> +	return ret;
>> +}
>
