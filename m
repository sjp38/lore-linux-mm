Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B04D86B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 21:43:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m5so250336440pfc.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 18:43:58 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id p90si29727754pfa.379.2017.05.25.18.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 18:43:58 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id w69so42543717pfk.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 18:43:58 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v3 2/8] x86/mm: Change the leave_mm() condition for local
 TLB flushes
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <61de238db6d9c9018db020c41047ce32dac64488.1495759610.git.luto@kernel.org>
Date: Thu, 25 May 2017 18:43:55 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <C67D3007-DA88-40DF-A8E8-8D7186675963@gmail.com>
References: <cover.1495759610.git.luto@kernel.org>
 <cover.1495759610.git.luto@kernel.org>
 <61de238db6d9c9018db020c41047ce32dac64488.1495759610.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>


> On May 25, 2017, at 5:47 PM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
> On a remote TLB flush, we leave_mm() if we're TLBSTATE_LAZY.  For a
> local flush_tlb_mm_range(), we leave_mm() if !current->mm.  These
> are approximately the same condition -- the scheduler sets lazy TLB
> mode when switching to a thread with no mm.
>=20
> I'm about to merge the local and remote flush code, but for ease of
> verifying and bisecting the patch, I want the local and remote flush
> behavior to match first.  This patch changes the local code to match
> the remote code.
>=20
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
> arch/x86/mm/tlb.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 776469cc54e0..3143c9a180e5 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -311,7 +311,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, =
unsigned long start,
> 		goto out;
> 	}
>=20
> -	if (!current->mm) {
> +	if (this_cpu_read(cpu_tlbstate.state) !=3D TLBSTATE_OK) {
> 		leave_mm(smp_processor_id());

Maybe it is an overkill, but you may want to have two variants: =
leave_mm()
and leave_mm_irq_off(). Currently, leave_mm() does not disable IRQs, but
in patch 6 it does. Here you indeed need to disable IRQs, but the cases
in prior to this patch - you do not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
