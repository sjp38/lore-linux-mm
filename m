Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 811B96B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 03:24:50 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id fl17so218396vcb.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 00:24:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANN689HM=h2k33sJcoDYys9LHVadv+NaGz00kG7O-OEH=qadvA@mail.gmail.com>
References: <508086DA.3010600@oracle.com>
	<5089A05E.7040000@gmail.com>
	<CA+1xoqf2v_jEapwU68BzXyi4abSRmi_=AiaJVHM3dBbHtsBnqQ@mail.gmail.com>
	<CAA_GA1d-rw_vkDF98fcf9E0=h86dsp+83-0_RE5b482juxaGVw@mail.gmail.com>
	<CANN689HXoCMTP4ZRMUNOGAdOBmizKyo6jMqbqAFx8wwPXp+AzQ@mail.gmail.com>
	<CAA_GA1eYHi4zWZwKp5KGi4gP7V8bfnSF=aLKMiN-Wi5JyLaCdw@mail.gmail.com>
	<CANN689HfmX8uBa17t38PYv2Ap5d3LPjShq81tbcgET5ZqzjzeQ@mail.gmail.com>
	<CANN689HM=h2k33sJcoDYys9LHVadv+NaGz00kG7O-OEH=qadvA@mail.gmail.com>
Date: Tue, 6 Nov 2012 00:24:49 -0800
Message-ID: <CANN689F6=mkJmgLFbALRPeYKG4RwTef+_r2TsHOLuobAxXbtPg@mail.gmail.com>
Subject: Re: mm: NULL ptr deref in anon_vma_interval_tree_verify
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, hughd@google.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Mon, Nov 5, 2012 at 5:41 AM, Michel Lespinasse <walken@google.com> wrote:
> On Sun, Nov 4, 2012 at 8:44 PM, Michel Lespinasse <walken@google.com> wrote:
>> On Sun, Nov 4, 2012 at 8:14 PM, Bob Liu <lliubbo@gmail.com> wrote:
>>> Hmm, I attached a simple fix patch.
>>
>> Reviewed-by: Michel Lespinasse <walken@google.com>
>> (also ran some tests with it, but I could never reproduce the original
>> issue anyway).
>
> Wait a minute, this is actually wrong. You need to call
> vma_lock_anon_vma() / vma_unlock_anon_vma() to avoid the issue with
> vma->anon_vma == NULL.
>
> I'll fix it and integrate it into my next patch series, which I intend
> to send later today. (I am adding new code into validate_mm(), so that
> it's easier to have it in the same patch series to avoid merge
> conflicts)

Hmmm, now I'm getting confused about anon_vma locking again :/

As Hugh privately remarked to me, the same_vma linked list is supposed
to be protected by exclusive mmap_sem ownership, not by anon_vma lock.
So now looking at it a bit more, I'm not sure what race we're
preventing by taking the anon_vma lock in validate_mm() ???

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
