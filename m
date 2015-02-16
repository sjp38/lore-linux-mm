Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id AC0A86B006C
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 09:01:32 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so31336432pdb.5
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:01:32 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id 4si2970611pdn.87.2015.02.16.06.01.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Feb 2015 06:01:31 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJV00KGKB54PF50@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Feb 2015 14:05:28 +0000 (GMT)
Content-transfer-encoding: 8BIT
Message-id: <54E1F834.4000408@samsung.com>
Date: Mon, 16 Feb 2015 17:01:24 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: Re: [PATCH v11 18/19] module: fix types of device tables aliases
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-19-git-send-email-a.ryabinin@samsung.com>
 <87d25aa83x.fsf@rustcorp.com.au>
In-reply-to: <87d25aa83x.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org

On 02/16/2015 05:44 AM, Rusty Russell wrote:
> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>> MODULE_DEVICE_TABLE() macro used to create aliases to device tables.
>> Normally alias should have the same type as aliased symbol.
>>
>> Device tables are arrays, so they have 'struct type##_device_id[x]'
>> types. Alias created by MODULE_DEVICE_TABLE() will have non-array type -
>> 	'struct type##_device_id'.
>>
>> This inconsistency confuses compiler, it could make a wrong
>> assumption about variable's size which leads KASan to
>> produce a false positive report about out of bounds access.
> 
> Hmm, as Andrew Morton points out, this breaks some usage; if we just
> fix the type (struct type##_device_id[]) will that work instead?
> 
> I'm guessing not, since typeof(x) will presumably preserve sizing
> information?
> 

Yes, this won't work.
In this particular case 'struct type##_device_id[]' would be equivalent
to 'struct type##_device_id[1]'

$ cat test.c
struct d {
        int a;
        int b;
};
struct d arr[] = {
        {1, 2}, {3, 4}, {}
};
extern struct d arr_alias[] __attribute__((alias("arr")));

$ gcc -c test.c
test.c:8:17: warning: array a??arr_aliasa?? assumed to have one element
 extern struct d arr_alias[] __attribute__((alias("arr")));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
