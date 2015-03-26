Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 692256B0070
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:32:41 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so65808987wgb.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:32:40 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id r4si28448697wix.67.2015.03.26.07.32.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 07:32:39 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 26 Mar 2015 14:32:37 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id C44DB17D810A
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 14:32:37 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2QEW9Qd1704388
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 14:32:09 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2QEW7Pm011521
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 08:32:09 -0600
Message-ID: <55141866.6080007@linux.vnet.ibm.com>
Date: Thu, 26 Mar 2015 15:32:06 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
References: <20150325121118.GA2542@gmail.com> <cover.1427289960.git.ldufour@linux.vnet.ibm.com> <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com> <20150325183316.GA9090@gmail.com> <20150325183647.GA9331@gmail.com> <1427317867.6468.87.camel@kernel.crashing.org> <20150326094330.GA15407@gmail.com> <5513E16D.1030101@linux.vnet.ibm.com> <20150326141730.GA23060@gmail.com>
In-Reply-To: <20150326141730.GA23060@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org

On 26/03/2015 15:17, Ingo Molnar wrote:
> 
> * Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
> 
>>> I argue we should use the right condition to clear vdso_base: if 
>>> the vDSO gets at least partially unmapped. Otherwise there's 
>>> little point in the whole patch: either correctly track whether 
>>> the vDSO is OK, or don't ...
>>
>> That's a good option, but it may be hard to achieve in the case the 
>> vDSO area has been splitted in multiple pieces.
>>
>> Not sure there is a right way to handle that, here this is a best 
>> effort, allowing a process to unmap its vDSO and having the 
>> sigreturn call done through the stack area (it has to make it 
>> executable).
>>
>> Anyway I'll dig into that, assuming that the vdso_base pointer 
>> should be clear if a part of the vDSO is moved or unmapped. The 
>> patch will be larger since I'll have to get the vDSO size which is 
>> private to the vdso.c file.
> 
> At least for munmap() I don't think that's a worry: once unmapped 
> (even if just partially), vdso_base becomes zero and won't ever be set 
> again.
> 
> So no need to track the zillion pieces, should there be any: Humpty 
> Dumpty won't be whole again, right?

My idea is to clear vdso_base if at least part of the vdso is unmap.
But since some part of the vdso may have been moved and unmapped later,
to be complete, the patch has to handle partial mremap() of the vDSO
too. Otherwise such a scenario will not be detected:

	new_area = mremap(vdso_base + page_size, ....);
	munmap(new_area,...);

>>> There's also the question of mprotect(): can users mprotect() the 
>>> vDSO on PowerPC?
>>
>> Yes, mprotect() the vDSO is allowed on PowerPC, as it is on x86, and 
>> certainly all the other architectures. Furthermore, if it is done on 
>> a partial part of the vDSO it is splitting the vma...
> 
> btw., CRIU's main purpose here is to reconstruct a vDSO that was 
> originally randomized, but whose address must now be reproduced as-is, 
> right?

You're right, CRIU has to move the vDSO to the same address it has at
checkpoint time.

> In that sense detecting the 'good' mremap() as your patch does should 
> do the trick and is certainly not objectionable IMHO - I was just 
> wondering whether we could make a perfect job very simply.

I'd try to address the perfect job, this may complexify the patch,
especially because the vdso's size is not recorded in the PowerPC
mm_context structure. Not sure it is a good idea to extend that structure..

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
