Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCBAA6B6C7D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 04:12:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b29-v6so1622489pfm.1
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 01:12:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l59-v6si19731262plb.519.2018.09.04.01.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 01:12:04 -0700 (PDT)
From: "Peng, DongX" <dongx.peng@intel.com>
Subject: RE: [RFC][PATCH 3/5] [PATCH 3/5] kvm-ept-idle: HVA indexed EPT read
Date: Tue, 4 Sep 2018 08:12:00 +0000
Message-ID: <5249147EF0246348BBCB3713DC3757BF8D0D0C@shsmsx102.ccr.corp.intel.com>
References: <20180901112818.126790961@intel.com>
 <20180901124811.591511876@intel.com>
 <37B30FD3-7955-4C0B-AAB5-544359F4D157@oracle.com>
In-Reply-To: <37B30FD3-7955-4C0B-AAB5-544359F4D157@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikita Leshenko <nikita.leshchenko@oracle.com>, "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "Liu, Jingqi" <jingqi.liu@intel.com>, "Dong, Eddie" <eddie.dong@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

kvm_get_kvm() kvm_put_kvm()

-----Original Message-----
From: Nikita Leshenko [mailto:nikita.leshchenko@oracle.com]=20
Sent: Tuesday, September 4, 2018 3:57 PM
To: Wu, Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>; Linux Memory Management List=
 <linux-mm@kvack.org>; Peng, DongX <dongx.peng@intel.com>; Liu, Jingqi <jin=
gqi.liu@intel.com>; Dong, Eddie <eddie.dong@intel.com>; Hansen, Dave <dave.=
hansen@intel.com>; Huang, Ying <ying.huang@intel.com>; Brendan Gregg <bgreg=
g@netflix.com>; kvm@vger.kernel.org; LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC][PATCH 3/5] [PATCH 3/5] kvm-ept-idle: HVA indexed EPT rea=
d

On 1 Sep 2018, at 13:28, Fengguang Wu <fengguang.wu@intel.com> wrote:
> +static ssize_t ept_idle_read(struct file *file, char *buf,
> +			     size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task =3D file->private_data;
> +	struct ept_idle_ctrl *eic;
> +	unsigned long hva_start =3D *ppos << BITMAP_BYTE2PVA_SHIFT;
> +	unsigned long hva_end =3D hva_start + (count << BITMAP_BYTE2PVA_SHIFT);
> +	int ret;
> +
> +	if (*ppos % IDLE_BITMAP_CHUNK_SIZE ||
> +	    count % IDLE_BITMAP_CHUNK_SIZE)
> +		return -EINVAL;
> +
> +	eic =3D kzalloc(sizeof(*eic), GFP_KERNEL);
> +	if (!eic)
> +		return -EBUSY;
> +
> +	eic->buf =3D buf;
> +	eic->buf_size =3D count;
> +	eic->kvm =3D task_kvm(task);
> +	if (!eic->kvm) {
> +		ret =3D -EINVAL;
> +		goto out_free;
> +	}
I think you need to increment the refcount while using kvm, otherwise kvm c=
an be destroyed from another thread while you're walking it.

-Nikita
> +
> +	ret =3D ept_idle_walk_hva_range(eic, hva_start, hva_end);
> +	if (ret)
> +		goto out_free;
> +
> +	ret =3D eic->bytes_copied;
> +	*ppos +=3D ret;
> +out_free:
> +	kfree(eic);
> +
> +	return ret;
> +}
