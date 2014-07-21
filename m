Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC756B0037
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:33:07 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so10291419pad.10
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:33:06 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id 1si7455033pdf.411.2014.07.21.10.33.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 10:33:06 -0700 (PDT)
Message-ID: <53CD4EB2.5020709@zytor.com>
Date: Mon, 21 Jul 2014 10:32:34 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>		 <53C58A69.3070207@zytor.com> <1405459404.28702.17.camel@misato.fc.hp.com>		 <03d059f5-b564-4530-9184-f91ca9d5c016@email.android.com>		 <1405546127.28702.85.camel@misato.fc.hp.com>	 <1405960298.30151.10.camel@misato.fc.hp.com> <53CD443A.6050804@zytor.com> <1405962993.30151.35.camel@misato.fc.hp.com>
In-Reply-To: <1405962993.30151.35.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de

On 07/21/2014 10:16 AM, Toshi Kani wrote:
> 
> You are right.  I was under a wrong impression that
> __change_page_attr() always splits a large pages into 4KB pages, but I
> overlooked the fact that it can handle a large page as well.  So, this
> approach does not work...
> 

If it did it would be a major fail.

>> I would also like a systematic way to deal with the fact
>> that Xen (sigh) is stuck with a separate mapping system.
>>
>> I guess Linux could adopt the Xen mappings if that makes it easier, as
>> long as that doesn't have a negative impact on native hardware -- we can
>> possibly deal with some older chips not being optimal.  
> 
> I see.  I agree that supporting the PAT bit is the right direction, but
> I do not know how much effort we need.  I will study on this.
> 
>> However, my thinking has been to have a "reverse PAT" table in memory of memory
>> types to encodings, both for regular and large pages.
> 
> I am not clear about your idea of the "reverse PAT" table.  Would you
> care to elaborate?  How is it different from using pte_val() being a
> paravirt function on Xen?

First of all, paravirt functions are the root of all evil, and we want
to reduce and eliminate them to the utmost level possible.  But yes, we
could plumb that up that way if we really need to.

What I'm thinking of is a table which can deal with both the moving PTE
bit, Xen, and the scattered encodings by having a small table from types
to encodings, and not use the encodings directly until fairly late it
the pipe.  I suspect, but I'm not sure, that we would also need the
inverse operation.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
