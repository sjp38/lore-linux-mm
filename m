Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 11EE46B0037
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:25:11 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id hq16so1017846vcb.23
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:25:10 -0700 (PDT)
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
        by mx.google.com with ESMTPS id up2si5181065vec.104.2014.05.20.10.25.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 10:25:10 -0700 (PDT)
Received: by mail-ve0-f174.google.com with SMTP id jw12so1026001veb.33
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:25:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140520172134.GJ2185@moon>
References: <cover.1400538962.git.luto@amacapital.net> <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
 <20140520172134.GJ2185@moon>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 20 May 2014 10:24:49 -0700
Message-ID: <CALCETrWSgjc+iymPrvC9xiz1z4PqQS9e9F5mRLNnuabWTjQGQQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix x86
 vdso naming
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>

On Tue, May 20, 2014 at 10:21 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Mon, May 19, 2014 at 03:58:33PM -0700, Andy Lutomirski wrote:
>> Using arch_vma_name to give special mappings a name is awkward.  x86
>> currently implements it by comparing the start address of the vma to
>> the expected address of the vdso.  This requires tracking the start
>> address of special mappings and is probably buggy if a special vma
>> is split or moved.
>>
>> Improve _install_special_mapping to just name the vma directly.  Use
>> it to give the x86 vvar area a name, which should make CRIU's life
>> easier.
>>
>> As a side effect, the vvar area will show up in core dumps.  This
>> could be considered weird and is fixable.  Thoughts?
>>
>> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
>> Cc: Pavel Emelyanov <xemul@parallels.com>
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>
> Hi Andy, thanks a lot for this! I must confess I don't yet know how
> would we deal with compat tasks but this is 'must have' mark which
> allow us to detect vvar area!

Out of curiosity, how does CRIU currently handle checkpointing a
restored task?  In current kernels, the "[vdso]" name in maps goes
away after mremapping the vdso.

I suspect that you'll need kernel changes for compat tasks, since I
think that mremapping the vdso on any reasonably modern hardware in a
32-bit task will cause sigreturn to blow up.  This could be fixed by
making mremap magical, although adding a new prctl or arch_prctl to
reliably move the vdso might be a better bet.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
