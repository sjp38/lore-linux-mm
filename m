Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD216B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 04:07:00 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id hn15so5288195igb.1
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 01:06:59 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id br4si15974194pbc.155.2014.09.16.01.06.56
        for <linux-mm@kvack.org>;
        Tue, 16 Sep 2014 01:06:56 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 09/10] x86, mpx: cleanup unused bound tables
Date: Tue, 16 Sep 2014 08:06:23 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017AE487@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-10-git-send-email-qiaowei.ren@intel.com>
 <541751DF.8090706@intel.com>
In-Reply-To: <541751DF.8090706@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 2014-09-16, Hansen, Dave wrote:
> On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
>> +/*
>> + * Free the backing physical pages of bounds table 'bt_addr'.
>> + * Assume start...end is within that bounds table.
>> + */
>> +static int __must_check zap_bt_entries(struct mm_struct *mm,
>> +		unsigned long bt_addr,
>> +		unsigned long start, unsigned long end) {
>> +	struct vm_area_struct *vma;
>> +
>> +	/* Find the vma which overlaps this bounds table */
>> +	vma =3D find_vma(mm, bt_addr);
>> +	/*
>> +	 * The table entry comes from userspace and could be
>> +	 * pointing anywhere, so make sure it is at least
>> +	 * pointing to valid memory.
>> +	 */
>> +	if (!vma || !(vma->vm_flags & VM_MPX) ||
>> +			vma->vm_start > bt_addr ||
>> +			vma->vm_end < bt_addr+MPX_BT_SIZE_BYTES)
>> +		return -EINVAL;
>=20
> If someone did *ANYTHING* to split the VMA, this check would fail.  I
> think that's a little draconian, considering that somebody could do a
> NUMA policy on part of a VM_MPX VMA and cause it to be split.
>=20
> This check should look across the entire 'bt_addr ->
> bt_addr+MPX_BT_SIZE_BYTES' range, find all of the VM_MPX VMAs, and zap
> only those.
>=20
> If we encounter a non-VM_MPX vma, it should be ignored.
>
Ok.

>> +	if (ret =3D=3D -EFAULT)
>> +		return ret;
>> +
>> +	/*
>> +	 * unmap those bounds table which are entirely covered in this
>> +	 * virtual address region.
>> +	 */
>=20
> Entirely covered *AND* not at the edges, right?
>=20
Yes.

>> +	bde_start =3D mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(start);
>> +	bde_end =3D mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(end-1);
>> +	for (bd_entry =3D bde_start + 1; bd_entry < bde_end; bd_entry++) {
>=20
> This needs a big fat comment that it is only freeing the bounds tables th=
at are 1.
> fully covered 2. not at the edges of the mapping, even if full aligned
>=20
> Does this get any nicer if we have unmap_side_bts() *ONLY* go after
> bounds tables that are partially owned by the region being unmapped?
>=20
> It seems like we really should do this:
>=20
> 	for (each bt fully owned)
> 		unmap_single_bt()
> 	if (start edge unaligned)
> 		free start edge
> 	if (end edge unaligned)
> 		free end edge
>=20
> I bet the unmap_side_bts() code gets simpler if we do that, too.
>=20
Maybe. I will try this.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
