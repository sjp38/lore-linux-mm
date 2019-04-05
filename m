Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 775F0C282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 199572146F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:32:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="WdLx0/KS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 199572146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBB326B0010; Fri,  5 Apr 2019 12:32:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6B6E6B0266; Fri,  5 Apr 2019 12:32:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0B986B0269; Fri,  5 Apr 2019 12:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA1B6B0010
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 12:32:28 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n23so4500313plp.23
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 09:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=kqcsrGTilJy4opNk7wpYgFnO9IX3q48oZ/se5d5Fh+A=;
        b=oDRGV31tlnSts0dDcVyIJkzpggzgRs+F+QY20BBLPEpvGAj+2Vel4YfoD5tr7WkdK/
         CijbEyLn377KMEQHOQS+9Vu4ACFTbVu8461j/f+O74IQhENB+g1EWmWcaY1owIsDh8mc
         2jgWDBl9Oc80k6RRAJtV8Kg8zhCKTJ82z6eumYzlsBcwZHApZ3KiMez05zmTNzSMN1uK
         NQYJKIg86BpVQZrp7EWuurtwD1QEyBiIN3Gc/bauZ2ENR14OKYoe3Dbt3IfNa0lVWMhM
         YYJPCi9ax2R8KIa0TjutUz1isLwYRBKJ/1PpRw/m6LZljDCDxT2ibnLR4gYXIVRBy/0r
         6LjA==
X-Gm-Message-State: APjAAAWPH8qFm+Me3+n78mtin9yseASuAt28KPcgEGxwU49Wsg7QSALq
	OqopXrAMaXMpRuC0TI1Oh3Q7NAJl/Kw9fk6O9eLj6eDGsUjVX6UW7CFVLEwpkr3zXSBJtiEPh/8
	dJvZHLuNC5KhLXDKGpmTXgwPmpdXBIk5QSKZ5uUJrM97nTlLkWNneXKstKTOaS4yndQ==
X-Received: by 2002:a17:902:1123:: with SMTP id d32mr14110225pla.16.1554481947915;
        Fri, 05 Apr 2019 09:32:27 -0700 (PDT)
X-Received: by 2002:a17:902:1123:: with SMTP id d32mr14110155pla.16.1554481947121;
        Fri, 05 Apr 2019 09:32:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554481947; cv=none;
        d=google.com; s=arc-20160816;
        b=UOtJh1B5bRIagB88zivDwfP/+TSKZIhHO0Lv4/XRDxhdkHTspVTxicxUHU4Fu3XguA
         YkroAnjeqv9DrnVdoel6aTpf9+P1MdV7HQiwfeXbXMq0egKRPTJn24FwnjnX86rJFJYw
         b8D/tZOsESwX6n7E10TfdMiSLs5j8bU7jleL87c3Qn7hCS6cEWE9yJVuGigRw2T4mw5X
         tr6E/Dg/kyftY+pzYVeirXdkVQwU/Fcz/O9nfqSIhqEwJ9qPkitUV9N0qoRTyniQAHqv
         hEGtmDZXxgQ00Bx0gNEqYfBTdSF9azk48dVz7pWKhksB0+kupY5qf1+z5UdTdySaSRgQ
         lAjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=kqcsrGTilJy4opNk7wpYgFnO9IX3q48oZ/se5d5Fh+A=;
        b=Gx3rs5yFkONelAzIjAHmcDtrW5bBIJUwKtJDhQCoc9TJgij3w4iOTscBCr8Rpluxq+
         onXOF+US1lwuEu0rnuxuqpAGeQh+R35zG44gBrcH5BTTG85IF7cuDiC4Q+GJMWEvXtT8
         HLrofQOfTPuEUYi5hgPpcSWvFRbpvFQGzlJ6QYufh7RejNatRI7d8KsYMYdiQ0MX5Lg1
         g55JZuwI2IWUCn9fLycRlwftlpY+s6XOlsqZUMMnQY9JtLr0iMlZ+CTTZJK8MV/9Ncx7
         TVEpMEPPbxY3Uto+MgO4BDo5SZwk41P01hkiAVgL2UpiVP1gumM3DJ11LiqWEl/DX+lK
         oClA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b="WdLx0/KS";
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a73sor4415089pge.24.2019.04.05.09.32.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 09:32:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b="WdLx0/KS";
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=kqcsrGTilJy4opNk7wpYgFnO9IX3q48oZ/se5d5Fh+A=;
        b=WdLx0/KSwL1WPu0snge32d6ZIdnUb3H6+B8O/RsVHhTweSt1p0DmoQfz2aWHWXhqas
         qo9Qemwz68tIaLAbZfwwo5CEcCjX0wtAsMDdgR2qlrZTKEkpZfPUpVRB9zkF3o/dZqzH
         DCiBYIZd1Wwd0tVhc+aIFGdw7GsagvAyHDz6bHzh3Gcx/tVZawPXNV0HZkqFPmSR6LGp
         kaWSbtOLyhQJxDPI+WIXNQZrDVVs1UFhRkQzV7feG5nviaCaAvjENz5ZKRzEhzeFanRw
         1uMXQuJizl4OetjSa0HD8AqfSYjRImGT2t3GkqEiTzAt2oA3jwK5bK4Kp/+dxyPhQk1q
         ww9Q==
X-Google-Smtp-Source: APXvYqygLiIChVcG2YU1rQkegW7uT2rvBBY5X3TPt/OOf0cq8B55fxMm9uUFI8xhMC+YNFeDkf7Tvw==
X-Received: by 2002:a63:2045:: with SMTP id r5mr13119100pgm.394.1554481946639;
        Fri, 05 Apr 2019 09:32:26 -0700 (PDT)
Received: from ?IPv6:2600:100e:b12a:ccdd:512d:55a6:36a5:bcd4? ([2600:100e:b12a:ccdd:512d:55a6:36a5:bcd4])
        by smtp.gmail.com with ESMTPSA id p2sm74419465pfi.73.2019.04.05.09.32.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 09:32:25 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16D57)
In-Reply-To: <20190405155603.GA12463@cisco>
Date: Fri, 5 Apr 2019 10:32:17 -0600
Cc: Dave Hansen <dave.hansen@intel.com>,
 Thomas Gleixner <tglx@linutronix.de>, Khalid Aziz <khalid.aziz@oracle.com>,
 Andy Lutomirski <luto@kernel.org>, Juerg Haefliger <juergh@gmail.com>,
 jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
 Kees Cook <keescook@google.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
 Tyler Hicks <tyhicks@canonical.com>,
 "Woodhouse, David" <dwmw@amazon.co.uk>,
 Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com,
 Joao Martins <joao.m.martins@oracle.com>,
 Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
 John Haxby <john.haxby@oracle.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
 Laura Abbott <labbott@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Aaron Lu <aaron.lu@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
 alexander.h.duyck@linux.intel.com, Amir Goldstein <amir73il@gmail.com>,
 Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com,
 anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
 Ben Hutchings <ben@decadent.org.uk>,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
 Catalin Marinas <catalin.marinas@arm.com>,
 Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org,
 Daniel Vetter <daniel.vetter@ffwll.ch>,
 Dan Williams <dan.j.williams@intel.com>,
 Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, James Morse <james.morse@arm.com>,
 Jann Horn <jannh@google.com>, Juergen Gross <jgross@suse.com>,
 Jiri Kosina <jkosina@suse.cz>, James Morris <jmorris@namei.org>,
 Joe Perches <joe@perches.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
 Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
 Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
 Mark Rutland <mark.rutland@arm.com>,
 Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>,
 Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
 pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
 richard.weiyang@gmail.com, Rik van Riel <riel@surriel.com>,
 David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>,
 Steven Rostedt <rostedt@goodmis.org>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
 "Serge E. Hallyn" <serge@hallyn.com>, Steve Capper <steve.capper@arm.com>,
 thymovanbeers@gmail.com, Vlastimil Babka <vbabka@suse.cz>,
 Will Deacon <will.deacon@arm.com>, Matthew Wilcox <willy@infradead.org>,
 yaojun8558363@gmail.com, Huang Ying <ying.huang@intel.com>,
 zhangshaokun@hisilicon.com, iommu@lists.linux-foundation.org,
 X86 ML <x86@kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Khalid Aziz <khalid@gonehiking.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <54380A49-2D32-46BE-AF30-A9930F461FCE@amacapital.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com> <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com> <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com> <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de> <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com> <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net> <20190405155603.GA12463@cisco>
To: Tycho Andersen <tycho@tycho.ws>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 5, 2019, at 9:56 AM, Tycho Andersen <tycho@tycho.ws> wrote:
>=20
>> On Fri, Apr 05, 2019 at 09:24:50AM -0600, Andy Lutomirski wrote:
>>=20
>>=20
>>> On Apr 5, 2019, at 8:44 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>>>=20
>>> On 4/5/19 12:17 AM, Thomas Gleixner wrote:
>>>>> process. Is that an acceptable trade-off?
>>>> You are not seriously asking whether creating a user controllable ret2d=
ir
>>>> attack window is a acceptable trade-off? April 1st was a few days ago.
>>>=20
>>> Well, let's not forget that this set at least takes us from "always
>>> vulnerable to ret2dir" to a choice between:
>>>=20
>>> 1. fast-ish and "vulnerable to ret2dir for a user-controllable window"
>>> 2. slow and "mitigated against ret2dir"
>>>=20
>>> Sounds like we need a mechanism that will do the deferred XPFO TLB
>>> flushes whenever the kernel is entered, and not _just_ at context switch=

>>> time.  This permits an app to run in userspace with stale kernel TLB
>>> entries as long as it wants... that's harmless.
>>=20
>> I don=E2=80=99t think this is good enough. The bad guys can enter the ker=
nel and arrange for the kernel to wait, *in kernel*, for long enough to set u=
p the attack.  userfaultfd is the most obvious way, but there are plenty. I s=
uppose we could do the flush at context switch *and* entry.  I bet that perf=
ormance still utterly sucks, though =E2=80=94 on many workloads, this turns e=
very entry into a full flush, and we already know exactly how much that suck=
s =E2=80=94 it=E2=80=99s identical to KPTI without PCID.  (And yes, if we go=
 this route, we need to merge this logic together =E2=80=94 we shouldn=E2=80=
=99t write CR3 twice on entry).
>>=20
>> I feel like this whole approach is misguided. ret2dir is not such a game c=
hanger that fixing it is worth huge slowdowns. I think all this effort shoul=
d be spent on some kind of sensible CFI. For example, we should be able to m=
ostly squash ret2anything by inserting a check that the high bits of RSP mat=
ch the value on the top of the stack before any code that pops RSP.  On an FP=
O build, there aren=E2=80=99t all that many hot POP RSP instructions, I thin=
k.
>>=20
>> (Actually, checking the bits is suboptimal. Do:
>>=20
>> unsigned long offset =3D *rsp - rsp;
>> offset >>=3D THREAD_SHIFT;
>> if (unlikely(offset))
>> BUG();
>> POP RSP;
>=20
> This is a neat trick, and definitely prevents going random places in
> the heap. But,
>=20
>> This means that it=E2=80=99s also impossible to trick a function to retur=
n into a buffer that is on that function=E2=80=99s stack.)
>=20
> Why is this true? All you're checking is that you can't shift the
> "location" of the stack. If you can inject stuff into a stack buffer,
> can't you just inject the right frame to return to your code as well,
> so you don't have to shift locations?
>=20
>=20

But the injected ROP payload will be *below* RSP, so you=E2=80=99ll need a g=
adget that can decrement RSP.  This makes the attack a good deal harder.

Something like RAP on top, or CET, will make this even harder.

>=20
> Tycho

