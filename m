Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 38D916B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 04:43:36 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so19484887wgg.10
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 01:43:35 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id x4si7307683wjf.110.2015.01.16.01.43.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 01:43:35 -0800 (PST)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 16 Jan 2015 09:43:35 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 023022190056
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:43:32 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0G9hXYc51839224
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:43:33 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0G9hWxN024393
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 02:43:32 -0700
Message-ID: <54B8DD44.1020402@de.ibm.com>
Date: Fri, 16 Jan 2015 10:43:32 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] ppc/kvm: Replace ACCESS_ONCE with READ_ONCE
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com> <1421312314-72330-2-git-send-email-borntraeger@de.ibm.com> <1421363369.23332.8.camel@ellerman.id.au>
In-Reply-To: <1421363369.23332.8.camel@ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org

Am 16.01.2015 um 00:09 schrieb Michael Ellerman:
> On Thu, 2015-01-15 at 09:58 +0100, Christian Borntraeger wrote:
>> ACCESS_ONCE does not work reliably on non-scalar types. For
>> example gcc 4.6 and 4.7 might remove the volatile tag for such
>> accesses during the SRA (scalar replacement of aggregates) step
>> (https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58145)
>>
>> Change the ppc/kvm code to replace ACCESS_ONCE with READ_ONCE.
>>
>> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
>> ---
>>  arch/powerpc/kvm/book3s_hv_rm_xics.c |  8 ++++----
>>  arch/powerpc/kvm/book3s_xics.c       | 16 ++++++++--------
>>  2 files changed, 12 insertions(+), 12 deletions(-)
>>
>> diff --git a/arch/powerpc/kvm/book3s_hv_rm_xics.c b/arch/powerpc/kvm/book3s_hv_rm_xics.c
>> index 7b066f6..7c22997 100644
>> --- a/arch/powerpc/kvm/book3s_hv_rm_xics.c
>> +++ b/arch/powerpc/kvm/book3s_hv_rm_xics.c
>> @@ -152,7 +152,7 @@ static void icp_rm_down_cppr(struct kvmppc_xics *xics, struct kvmppc_icp *icp,
>>  	 * in virtual mode.
>>  	 */
>>  	do {
>> -		old_state = new_state = ACCESS_ONCE(icp->state);
>> +		old_state = new_state = READ_ONCE(icp->state);
> 
> These are all icp->state.
> 
> Which is a union, but it's only the size of unsigned long. So in practice there
> shouldn't be a bug here right?

This bug was that gcc lost the volatile tag when propagating aggregates to scalar types.
So in theory a union could be affected. See the original problem
 ( http://marc.info/?i=54611D86.4040306%40de.ibm.com ) 
which happened on 

union ipte_control {
        unsigned long val;
        struct {
                unsigned long k  : 1;
                unsigned long kh : 31;
                unsigned long kg : 32;
        };
};

Christian


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
