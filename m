Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB5A6B026A
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 01:49:45 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id n32so6401048qtb.5
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 22:49:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c15si4906648qtk.86.2018.01.06.22.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jan 2018 22:49:44 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.21) with SMTP id w076nRVV132067
	for <linux-mm@kvack.org>; Sun, 7 Jan 2018 01:49:44 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fbcth3e8n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 07 Jan 2018 01:49:43 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 7 Jan 2018 06:49:41 -0000
Subject: Re: mmotm 2018-01-04-16-19 uploaded
References: <5a4ec4bc.u5I/HzCSE6TLVn02%akpm@linux-foundation.org>
 <7e35e16a-d71c-2ec8-03ed-b07c2af562f8@linux.vnet.ibm.com>
 <20180105084631.GG2801@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sun, 7 Jan 2018 12:19:32 +0530
MIME-Version: 1.0
In-Reply-To: <20180105084631.GG2801@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <e81dce2b-5d47-b7d3-efbf-27bc171ba4ab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On 01/05/2018 02:16 PM, Michal Hocko wrote:
> On Fri 05-01-18 12:13:17, Anshuman Khandual wrote:
>> On 01/05/2018 05:50 AM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2018-01-04-16-19 has been uploaded to

[...]

>>>
>>> This tree is partially included in linux-next.  To see which patches are
>>> included in linux-next, consult the `series' file.  Only the patches
>>> within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
>>> linux-next.
>>>
>>> A git tree which contains the memory management portion of this tree is
>>> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
>> Seems like this latest snapshot mmotm-2018-01-04-16-19 has not been
>> updated in this git tree. I could not fetch not it shows up in the
>> http link below.
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> I will update the tree today (WIP). This is not a fully automated
> process and Andrew pushed his tree during my night ;) So be patient
> please. My tree is non-rebasing which means I cannot just throw the old
> tree away and regenerate it from scratch.
> 
>> The last one mmotm-2017-12-22-17-55 seems to have some regression on
>> powerpc with respect to ELF loading of binaries (see below). Seems to
>> be related to recent MAP_FIXED_SAFE (or MAP_FIXED_NOREPLACE as seen
>> now in the code). IIUC (have not been following the series last month)
>> MAP_FIXED_NOREPLACE will fail an allocation request if the hint address
>> cannot be reserve instead of changing existing mappings.
> Correct
> 
>> Is it possible
>> that ELF loading needs to be fixed at a higher level to deal with these
>> new possible mmap() failures because of MAP_FIXED_NOREPLACE ?
> Could you give us more information about the failure please. Debugging
> patch from http://lkml.kernel.org/r/20171218091302.GL16951@dhcp22.suse.cz
> should help to see what is the clashing VMA.

Seems like its re-requesting the same mapping again.

[   23.423642] 9148 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
[   23.423706] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.426089] 9151 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
[   23.426232] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.429048] 9154 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
[   23.429196] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.482766] 9164 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
[   23.482904] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.485849] 9167 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
[   23.485945] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   76.041836] 9262 (hostname): Uhuuh, elf segment at 0000000010020000 requested but the memory is mapped already
[   76.041965] requested [10020000, 10030000] mapped [10020000, 10030000] 100073 anon
[   76.207197] 9285 (pkg-config): Uhuuh, elf segment at 0000000010020000 requested but the memory is mapped already
[   76.207326] requested [10020000, 10030000] mapped [10020000, 10030000] 100073 anon
[   76.371073] 9299 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
[   76.371165] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon


I have fixed/changed the debug patch a bit


diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index d8c5657..a43eccaa 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -372,11 +372,35 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
        } else
                map_addr = vm_mmap(filep, addr, size, prot, type, off);

-       if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr))
+       if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr)) {
+               struct vm_area_struct *vma;
+               unsigned long end;
+
+               if (total_size)
+                       end = addr + total_size;
+               else
+                       end = addr + size;
+
                pr_info("%d (%s): Uhuuh, elf segment at %p requested but the memory is mapped already\n",
                                task_pid_nr(current), current->comm,
                                (void *)addr);

+               vma = find_vma(current->mm, addr);
+               if (vma && vma->vm_start <= addr) {
+                       pr_info("requested [%lx, %lx] mapped [%lx, %lx] %lx ", addr, end,
+                                       vma->vm_start, vma->vm_end, vma->vm_flags);
+                       if (!vma->vm_file) {
+                               pr_cont("anon\n");
+                       } else {
+                               char path[512];
+                               char *p = file_path(vma->vm_file, path, sizeof(path));
+                               if (IS_ERR(p))
+                                       p = "?";
+                               pr_cont("\"%s\"\n", kbasename(p));
+                       }
+                       dump_stack();
+               }
+       }
        return(map_addr);
 }




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
