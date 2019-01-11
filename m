Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 572E98E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:28:30 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id y2so8714309plr.8
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:28:30 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id w16si72155237pga.328.2019.01.11.10.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 10:28:29 -0800 (PST)
Subject: Re: [RFC PATCH v7 07/16] arm64/mm, xpfo: temporarily map dcache
 regions
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <eba179acbfdea5a646c5548cb82138c1c3b74aa2.1547153058.git.khalid.aziz@oracle.com>
 <20190111145445.GA4102@cisco>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <19e61a22-bbae-d0ae-8d41-158d4b46bf01@oracle.com>
Date: Fri, 11 Jan 2019 11:28:19 -0700
MIME-Version: 1.0
In-Reply-To: <20190111145445.GA4102@cisco>
Content-Type: multipart/mixed;
 boundary="------------3BB60CD6A7EC85D34E24789D"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@tycho.ws>
Cc: juergh@gmail.com, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com, Juerg Haefliger <juerg.haefliger@canonical.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This is a multi-part message in MIME format.
--------------3BB60CD6A7EC85D34E24789D
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 1/11/19 7:54 AM, Tycho Andersen wrote:
> On Thu, Jan 10, 2019 at 02:09:39PM -0700, Khalid Aziz wrote:
>> From: Juerg Haefliger <juerg.haefliger@canonical.com>
>>
>> If the page is unmapped by XPFO, a data cache flush results in a fatal=

>> page fault, so let's temporarily map the region, flush the cache, and =
then
>> unmap it.
>>
>> v6: actually flush in the face of xpfo, and temporarily map the underl=
ying
>>     memory so it can be flushed correctly
>>
>> CC: linux-arm-kernel@lists.infradead.org
>> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
>> Signed-off-by: Tycho Andersen <tycho@docker.com>
>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>> ---
>>  arch/arm64/mm/flush.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
>> index 30695a868107..f12f26b60319 100644
>> --- a/arch/arm64/mm/flush.c
>> +++ b/arch/arm64/mm/flush.c
>> @@ -20,6 +20,7 @@
>>  #include <linux/export.h>
>>  #include <linux/mm.h>
>>  #include <linux/pagemap.h>
>> +#include <linux/xpfo.h>
>> =20
>>  #include <asm/cacheflush.h>
>>  #include <asm/cache.h>
>> @@ -28,9 +29,15 @@
>>  void sync_icache_aliases(void *kaddr, unsigned long len)
>>  {
>>  	unsigned long addr =3D (unsigned long)kaddr;
>> +	unsigned long num_pages =3D XPFO_NUM_PAGES(addr, len);
>> +	void *mapping[num_pages];
>=20
> Does this still compile with -Wvla? It was a bad hack on my part, and
> we should probably just drop it and come up with something else :)

I will make a note of it. I hope someone with better knowledge of arm64
than me can come up with a better solution ;)

--
Khalid

>=20
> Tycho
>=20
>>  	if (icache_is_aliasing()) {
>> +		xpfo_temp_map(kaddr, len, mapping,
>> +			      sizeof(mapping[0]) * num_pages);
>>  		__clean_dcache_area_pou(kaddr, len);
>> +		xpfo_temp_unmap(kaddr, len, mapping,
>> +			        sizeof(mapping[0]) * num_pages);
>>  		__flush_icache_all();
>>  	} else {
>>  		flush_icache_range(addr, addr + len);
>> --=20
>> 2.17.1
>>


--------------3BB60CD6A7EC85D34E24789D
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

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
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------3BB60CD6A7EC85D34E24789D--
