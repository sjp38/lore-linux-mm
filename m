Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 818E56B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:52:18 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so4337148yhz.22
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:52:18 -0800 (PST)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id y62si15157246yhc.169.2013.12.10.13.52.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 13:52:17 -0800 (PST)
Received: by mail-ie0-f169.google.com with SMTP id e14so9801419iej.28
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:52:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52A787D0.2070400@zytor.com>
References: <52A6D9B0.7040506@huawei.com>
	<CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com>
	<52A787D0.2070400@zytor.com>
Date: Tue, 10 Dec 2013 13:52:16 -0800
Message-ID: <CAE9FiQU8Y_thGxZamz0Uwt4FGXh7KJu7jGP8ED3dbjQuyq7vcQ@mail.gmail.com>
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Tue, Dec 10, 2013 at 1:29 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 12/10/2013 01:06 PM, Yinghai Lu wrote:
>> On Tue, Dec 10, 2013 at 1:06 AM, Xishi Qiu <qiuxishi@huawei.com> wrote:
>>> In the following case, e820_all_mapped() will return 1.
>>> A < start < B-1 and B < end < C, it means <start, end> spans two regions.
>>> <start, end>:           [start - end]
>>> e820 addr:          ...[A - B-1][B - C]...
>>
>> should be [start, end) right?
>> and
>> [A, B),[B, C)
>>
>
> What happens if it spans more than two regions?

[A, B), [B+1, C), [C+1, D) ?
start in [A, B), and end in [C+1, D).

old code:
first with [A, B), start set to B.
then with [B+1, C), start still keep as B.
then with [C+1, D), start still keep as B.
at last still return 0...aka not_all_mapped.

old code is still right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
