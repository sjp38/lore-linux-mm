Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A699C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 17:56:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D3E120820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 17:56:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="Sehk7xk8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D3E120820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26B7C6B000E; Thu,  4 Apr 2019 13:56:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 243546B0266; Thu,  4 Apr 2019 13:56:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 132406B0269; Thu,  4 Apr 2019 13:56:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D21956B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 13:56:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c64so2237077pfb.6
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 10:56:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:content-transfer-encoding:from
         :mime-version:subject:date:message-id:references:cc:in-reply-to:to;
        bh=y0ikJY58io4Wa43GQnKYccs9io+2yziuZbvEkKCZrDU=;
        b=cz2R1Gls/6/SLwocfGE5ocZ3Aku5QsbSYQLi5zS8SKlRLkRaFlf7N4QaK5T2aTwO0e
         VI5bMu2gjwwERFyazGDNLKZmBbeMdfRmp8/nE3UanhGYS0kgW6mSzSulEIbF6uoViAkr
         YfWCIfSj3wG0mVtXhtjvvNIn+0AQR3ilwgsin3EGhGcfat3DgqM4QAUIgvVNnqtrxBpM
         6GIPRFj0FDZKi+7qYmLPt4vMend4NJLbQwHk39U5EIlMFkEy7fUaCT/43hNFv9z8G7FW
         X1Xn6HUrS2aXI7iA8EhZHlB0i4LYN22PSL2L2tNwc8YUz7e3dXYWVF6yOKU6ncn8BDye
         j7oQ==
X-Gm-Message-State: APjAAAW79RPArZZbVRefsuSPiwdJv/+HQFuYGw5YVWRwPKjxLrDbiQ+5
	ZoK+6dATWZYeMXTDTEOUvyFSWTN6QvnionRdfGuH3oT8ffbPOn5b31KvByjbKoxvncj5d/9Gv8j
	Mjqk4JMnfrN4idqaNxr9uGs1KMzomB/Amqm9QyJeMDJxIKqmSQ6fRnmEbMw4IXE0J3w==
X-Received: by 2002:a63:5854:: with SMTP id i20mr7012818pgm.171.1554400592398;
        Thu, 04 Apr 2019 10:56:32 -0700 (PDT)
X-Received: by 2002:a63:5854:: with SMTP id i20mr7012743pgm.171.1554400591370;
        Thu, 04 Apr 2019 10:56:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554400591; cv=none;
        d=google.com; s=arc-20160816;
        b=hm1CpsqtMyZxmOXmoH1t1O3d4k7f8wYugb3gG9uUcBoAzKZ59xhCFYiMBHLTdblscR
         TcULHAMQTo3o9vpq/vniMxxNRh+EdR8nv8g54c8AIe2+uQUGR6Q/H69e8Utp2Khw1PaJ
         vqmYJzD3FgINUvKJ+5jWL0ORAYpB7jdoJfysUZozKfWLOvDXWcgVbsVNMPLLLaxPMI3k
         zrzSBx2G++AOYUKpVFKfVMcA0xBIL7HI3rxsopxtU2PEE1IXYL7uMjI2z+8XDxqp4ExE
         k1YywqaDZnvOfZ7L0gkP6r27YtB2Iz2qPxFHIZfNZPEpvrgevwpbQSsjsToHFHaIaqRm
         EbCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:in-reply-to:cc:references:message-id:date:subject:mime-version
         :from:content-transfer-encoding:dkim-signature;
        bh=y0ikJY58io4Wa43GQnKYccs9io+2yziuZbvEkKCZrDU=;
        b=qNv73NhSvsTFw2bzHWpMFR3qb3exgkscLkC54lM+1izvxM7cOnmJkF25LPG2ND2r6R
         RzmuWLQZwRZlLgBmCU4kQ9CNHo0yt1Eoo6+9MGjJ1G9RuBajI2xxUoR5pi0PFj5+J4It
         RTfiM1NSStQzNvEKlcV2o7qYsIEcItnAkDye0QvzHeMqeQ7+gqwZ/u9XJz81Wl+0Uq6B
         xWJiNsSF149bEAmE/+r6XebiPNkHvinDw85pzvLOI2fov0BDAaPVHV5omxkvIGaNfcQi
         nmml1rAeFxDL1pKsirSbLH1EUR5z10zDHctIj1nyznB6q7hoQKeeTC0P6KB2ceBALe7d
         8qXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Sehk7xk8;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20sor9037781pgs.48.2019.04.04.10.56.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 10:56:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Sehk7xk8;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=content-transfer-encoding:from:mime-version:subject:date:message-id
         :references:cc:in-reply-to:to;
        bh=y0ikJY58io4Wa43GQnKYccs9io+2yziuZbvEkKCZrDU=;
        b=Sehk7xk8bQTT/JxDFUPGFRFUxYLcsMQfrRfyew7KbuwYh+M/QEXM9ZaamFa1jOkCQp
         eMJ74VXovK6NkKdNMf1h3rqNy2t6VErLaikALh6op6mJTiurskotkpTSY2H1PI9ro+vz
         KPT/LK1Oq5KRkeXLgFoOntbXBtxIR+meVXx3TbbXU5dntbU84ZxAcy5vVJzNjiJts1As
         +fm2cXOMg1f60AlVkqilZB5axHaLY3TwSGTCo3FHkUh0bkkITqegzvwe58atgnZ+XoV2
         qobq+IUPv9Jc+Ic+HbBOdlbQGdEA+rftY+foKBKLo17ZlfL9kywDHzJXXqDgXWW8yc0I
         rwBw==
X-Google-Smtp-Source: APXvYqzVPc+o8FBoYa5cZ2Xwpr8Ai4pdgWd+NNbqNTAlXHSLkbDlkmIow3W1gY2wDZUHI4qWeK1HPA==
X-Received: by 2002:a63:d1f:: with SMTP id c31mr7086401pgl.353.1554400590778;
        Thu, 04 Apr 2019 10:56:30 -0700 (PDT)
Received: from [10.233.172.192] (233.sub-97-41-130.myvzw.com. [97.41.130.233])
        by smtp.gmail.com with ESMTPSA id v20sm24623076pfe.118.2019.04.04.10.56.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 10:56:29 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v9 02/13] x86: always set IF before oopsing from page fault
Date: Thu, 4 Apr 2019 11:11:26 -0600
Message-Id: <8876301F-C720-4DFD-8D01-F9C526E21A10@amacapital.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com> <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com> <20190404013956.GA3365@cisco> <CALCETrVp37Xo3EMHkeedP1zxUMf9og=mceBa8c55e1F4G1DRSQ@mail.gmail.com> <20190404154727.GA14030@cisco> <alpine.DEB.2.21.1904041822320.1802@nanos.tec.linutronix.de>
Cc: Tycho Andersen <tycho@tycho.ws>, Andy Lutomirski <luto@kernel.org>,
 Khalid Aziz <khalid.aziz@oracle.com>, Juerg Haefliger <juergh@gmail.com>,
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
 Laura Abbott <labbott@redhat.com>, Dave Hansen <dave.hansen@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, Aaron Lu <aaron.lu@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
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
 richard.weiyang@gmail.com, "Serge E. Hallyn" <serge@hallyn.com>,
 iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Khalid Aziz <khalid@gonehiking.org>
In-Reply-To: <alpine.DEB.2.21.1904041822320.1802@nanos.tec.linutronix.de>
To: Thomas Gleixner <tglx@linutronix.de>
X-Mailer: iPhone Mail (16D57)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> On Apr 4, 2019, at 10:28 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>=20
>> On Thu, 4 Apr 2019, Tycho Andersen wrote:
>>    leaq    -PTREGS_SIZE(%rax), %rsp
>>    UNWIND_HINT_FUNC sp_offset=3DPTREGS_SIZE
>>=20
>> +    /*
>> +     * If we oopsed in an interrupt handler, interrupts may be off. Let'=
s turn
>> +     * them back on before going back to "normal" code.
>> +     */
>> +    sti
>=20
> That breaks the paravirt muck and tracing/lockdep.
>=20
> ENABLE_INTERRUPTS() is what you want plus TRACE_IRQ_ON to keep the tracer
> and lockdep happy.
>=20
>=20

I=E2=80=99m sure we=E2=80=99ll find some other thing we forgot to reset even=
tually, so let=E2=80=99s do this in C.  Change the call do_exit to call __fi=
nish_rewind_stack_do_exit and add the latter as a C function that does local=
_irq_enable() and do_exit().=

