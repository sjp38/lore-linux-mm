Date: Sat, 07 Jan 2006 12:09:29 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <2796BAF66E63B415FF1929B8@[10.1.1.4]>
In-Reply-To: <20060107122534.GA20442@osiris.boeblingen.de.ibm.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <20060107122534.GA20442@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Saturday, January 07, 2006 13:25:34 +0100 Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:

>> The primary purpose of sharing page tables is improved performance for
>> large applications that share big memory areas between multiple
>> processes. It eliminates the redundant page tables and significantly
>> reduces the number of minor page faults.  Tests show significant
>> performance improvement for large database applications, including those
>> using large pages.  There is no measurable performance degradation for
>> small processes.
> 
> Tried to get this running with CONFIG_PTSHARE and CONFIG_PTSHARE_PTE on
> s390x. Unfortunately it crashed on boot, because pt_share_pte
> returned a broken pte pointer:

The patch as submitted only works on i386 and x86_64.  Sorry.

>> +pte_t *pt_share_pte(struct vm_area_struct *vma, unsigned long address,
>> pmd_t *pmd, + ...
>> +	pmd_val(spmde) = 0;
>> + ...
>> +		if (pmd_present(spmde)) {
> 
> This is wrong. A pmd_val of 0 will make pmd_present return true on s390x
> which is not what you want.
> Should be pmd_clear(&spmde).
> 
>> +pmd_t *pt_share_pmd(struct vm_area_struct *vma, unsigned long address,
>> pud_t *pud, + ...
>> +	pud_val(spude) = 0;
> 
> Should be pud_clear, I guess :)

Yes, you're right.  pmd_clear() and pud_clear() would be more portable.
I'll make that change.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
