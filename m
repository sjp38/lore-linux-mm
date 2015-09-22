Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5566B0254
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:49:28 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so6466398qkf.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:49:28 -0700 (PDT)
Received: from mail-qk0-x235.google.com (mail-qk0-x235.google.com. [2607:f8b0:400d:c09::235])
        by mx.google.com with ESMTPS id 143si2331326qhy.11.2015.09.22.09.49.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 09:49:27 -0700 (PDT)
Received: by qkcf65 with SMTP id f65so6464626qkc.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:49:27 -0700 (PDT)
Subject: Re: [PATCH 0/2] prepare zbud to be used by zram as underlying
 allocator
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
 <20150917013007.GB421@swordfish>
 <CAMJBoFP5LfoKwzDbSJMmOVOfq=8-7AaoAOV5TVPNt-JcUvZ0eA@mail.gmail.com>
 <20150921041837.GF27729@bbox>
 <CAMJBoFN0KocBQLSMJkxYS2JS+jSPR3Y5gGdceoKTYJWbm06t1g@mail.gmail.com>
 <20150922153640.GA14817@bbox>
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <56018695.5030700@gmail.com>
Date: Tue, 22 Sep 2015 12:49:25 -0400
MIME-Version: 1.0
In-Reply-To: <20150922153640.GA14817@bbox>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms060901050207080706030800"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Vitaly Wool <vitalywool@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

This is a cryptographically signed message in MIME format.

--------------ms060901050207080706030800
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-09-22 11:36, Minchan Kim wrote:
> Hi Vitaly,
>
> On Mon, Sep 21, 2015 at 11:11:00PM +0200, Vitaly Wool wrote:
>> Hello Minchan,
>>
>>> Sorry, because you wrote up "zram" in the title.
>>> As I said earlier, we need several numbers to investigate.
>>>
>>> First of all, what is culprit of your latency?
>>> It seems you are thinking about compaction. so compaction what?
>>> Frequent scanning? lock collision? or frequent sleeping in compaction=

>>> code somewhere? And then why does zbud solve it? If we use zbud for z=
ram,
>>> we lose memory efficiency so there is something to justify it.
>>
>> The data I've got so far strongly suggests that in some use cases (see=

>> below) with zsmalloc
>> * there are more allocstalls
>> * memory compaction is triggered more frequently
>> * allocstalls happen more often
>> * page migrations are way more frequent, too.
>>
>> Please also keep in mind that I do not advise you or anyone to use
>> zbud instead of zsmalloc. The point I'm trying to make is that zbud
>> fits my particular case better and I want to be able to choose it in
>> the kernel without hacking it with my private patches.
>
> I understand your goal well. ;-) But, please understand my goal which
> is to find fundamental reason why zbud removes latency.
>
> You gave some compaction-related stats but it is just one of result,
> not the cause. I guess you could find another stats as well as compacti=
on
> stats which affect your workload. Once you find them all, please
> investigate what is major factor for your latency among them.
> Then, we should think over what is best solution for it and if zbud is
> best to remove the cause, yes, why not. I can merge it into zram.
>
> IOW, I should maintain zram so I need to know when,where,how to use zbu=
d
> with zram is useful so that I can guide it to zram users and you should=

> *justify* the overhead to me. Overhead means I should maintain two allo=
cators
> for zram from now on. It means when I want to add some feature for zsma=
lloc,
> I should take care of zbud and I should watch zbud patches, too which c=
ould
> be very painful and starting point of diverge for zram.
>
> Compared to zsmalloc, zsmalloc packs lots of compressed objects into
> a page while zbud just stores two objects so if there are different
> life time objects in a page, zsmalloc may make higher fragmentation
> but zbud is not a good choice for memory efficiency either so my concer=
n
> starts from here.
>
> For solving such problem, we added compaction into recent zram to
> reduce waste memory space so it should solve internal fragment problem.=

> Other problem we don't solve now is external fragmentation which
> is related to compaction stats you are seeing now.
> Although you are seeing mitigation with zbud, it would be still problem=

> if you begin to use more memory for zbud. One of example, a few years
> ago, some guys tried to support zbud page migration.
>
> If external fragmentation is really problem in here, we should proivde
> a feature VM can migrate zsmalloc page and it was alomost done as I tol=
d
> you previous thread and I think it is really way to go.
>
> Even, we are trying to add zlib which is better compress ratio algorith=
m
> to reduce working memory size so without the feature, the problem would=
 be
> more severe.
>
> So, I am thinking now we should enhance it rather than hiding a problem=

> by merging zbud.
You know,from my perspective, most of the above argument 'against' zbud=20
being supported really provides no actual reason to not support zbud=20
without reading between the lines (which as far as I can tell, is 'I=20
just don't want to support it'), it just points out all the differences=20
between zsmalloc and zbud.  They are different API's, they have=20
different semantics, they are intended for different workloads and use=20
cases, and this will always be the case.  To be entirely honest, the=20
more complicated you make zsmalloc in an attempt to obviate the need to=20
support zbud, the more attractive zbud looks as far as I'm concerned.
>
>> FWIW, given that I am not an author of either, I don't see why anyone
>> would consider me biased. :-)
>>
>> As of the memory efficiency, you seem to be quite comfortable with
>> storing uncompressed pages when they compress to more than 3/4 of a
>> page. I observed ~13% reported ratio increase (3.8x to 4.3x) when I
>> increased max_zpage_size to PAGE_SIZE / 32 * 31. Doesn't look like a
>> fight for every byte to me.
>
> Thanks for the report. It could be another patch. :)
>
>>
>>> The reason I am asking is I have investigated similar problems
>>> in android and other plaforms and the reason of latency was not zsmal=
loc
>>> but agressive high-order allocations from subsystems, watermark check=

>>> race, deferring of compaction, LMK not working and too much swapout s=
o
>>> it causes to reclaim lots of page cache pages which was main culprit
>>> in my cases. When I checks with perf, compaction stall count is incre=
ased,
>>> the time spent in there is not huge so it was not main factor of late=
ncy.
>>
>> The main use case where the difference is seen is switching between
>> users on an Android device. It does cause a lot of reclaim, too, as
>> you say, but this is in the nature of zbud that reclaim happens in a
>> more deterministic way and worst-case looks substantially nicer. That
>
> Interesting!
> Why is reclaim more deterministic with zbud?
> That's really one of part what I want with data.
I'm pretty sure this is due to the fact that zbud stores at most 2=20
compressed pages in a given page, combined with fewer conditionals in=20
the reclaim path.
>
>
>> said, the standard deviation calculated over 20 iterations of a
>> change-user-multiple-times-test is 2x less for zbud than the one of
>> zsmalloc.
>
> One thing I can guess is a page could be freed easily if just two objec=
ts
> in a page are freed by munmap or kill. IOW, we could remove pinned page=

> easily so we could get higher-order page easily.
>
> However, it would be different once zbud's memory usgae is higher
> as I mentioned. As well, we lose memory efficieny significantly for zra=
m. :(
Not everyone who uses zram cares hugely about memory efficiency, I for=20
one would rather have a more deterministic compression ratio (which zbud =

achieves) than slightly better memory efficiencyg.
>
> IMO, more fundamentatal solution is to support VM-aware compaction of
> zsmalloc/zbud rather than hiding a problem with zbud.



--------------ms060901050207080706030800
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwOTIyMTY0OTI1WjBPBgkq
hkiG9w0BCQQxQgRAiKSeEZLoPU0Q+pPLTDRwl98jslYonZBLIrVLmDemX6KcI9bzbAcHhjjg
ClSuDKDS1Qi/eItjwP51diIWtNZfZjBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgBt0pwRCf0HrUjPw6wP05hXX1tRtm/ocpc6C/KQGpMBraG30Okc
7qRL6pWefV9DA6AeNIlGS6Rm9mmQCp56Q8cB+BqL/eSM63tjBX3hQgc762NPlwH2GmUVmtJi
CKKz5pbWK9sAuq0juKMr3HnPvNDHU6AOW4k9CgsEGqGNThlEDq5shPUm7O4Vflto2U9ykKZZ
xqOtJ2Y8kqEZ2yXHz1r4Uq0fwgHohND9hgV/bC0sGqscIKtALYxebaaOpem+O1Y7MwZnRefb
J/6u7H8LeRaQuvACwbsRpEC2DL1qdKUlefMSRKT6S3tG0R/EUMw84UBTv8WKBYYhVqmFJEI6
jHxRdeqaByEcZpa1MMRuObCIVl+9kTuKbKPy1cqFvC8U79zXu08x6TUMLlXVvlrVwCtV7ip1
zFdp9AbjsJoTvSvHSEL9StzGaeACsbA/aVhv5VCnUlpor/d0A0TkZ9QcGH+sTAhDw9Q9eI70
dyYG29g85FcJ9ObCnmwXVquhtDbjkZZoiYMdHG71LCfs3aNNmCibuv75AxPvNiGLxYu3Nrnj
wKW2qcskwabBKbWX6PxvSZ4juv7gDUvFCfEW+WIK+Rx0iY9hMp67PlGHLp1xsy8yLuJW5RbW
VwVG1A40PPXHaVDF2Ll4Iti+FUkpjYl+uXcAjrrNZ1N2OAJtFBz+FhLbQgAAAAAAAA==
--------------ms060901050207080706030800--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
