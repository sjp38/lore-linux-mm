Return-Path: <linux-kernel-owner@vger.kernel.org>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: Bug with report THP eligibility for each vma
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181224074916.GB9063@dhcp22.suse.cz>
Date: Mon, 24 Dec 2018 04:35:28 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <78624B4A-EA8B-4D51-B3E6-448132BB839B@oracle.com>
References: <CALouPAi8KEuPw_Ly5W=MkYi8Yw3J6vr8mVezYaxxVyKCxH1x_g@mail.gmail.com>
 <20181224074916.GB9063@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@suse.com>
Cc: Paul Oppenheimer <bepvte@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Jan Kara <jack@suse.cz>, Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>



> On Dec 24, 2018, at 12:49 AM, Michal Hocko <mhocko@suse.com> wrote:
>=20
> [Cc-ing mailing list and people involved in the original patch]
>=20
> On Fri 21-12-18 13:42:24, Paul Oppenheimer wrote:
>> Hello! I've never reported a kernel bug before, and since its on the
>> "next" tree I was told to email the author of the relevant commit.
>> Please redirect me to the correct place if I've made a mistake.
>>=20
>> When opening firefox or chrome, and using it for a good 7 seconds, it
>> hangs in "uninterruptible sleep" and I recieve a "BUG" in dmesg. This
>> doesn't occur when reverting this commit:
>> =
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit=
/?id=3D48cf516f8c.
>> Ive attached the output of decode_stacktrace.sh and the relevant =
dmesg
>> log to this email.
>>=20
>> Thanks
>=20
>> BUG: unable to handle kernel NULL pointer dereference at =
00000000000000e8
>=20
> Thanks for the bug report! This is offset 232 and that matches
> file->f_mapping as per pahole
> pahole -C file ./vmlinux | grep f_mapping
>        struct address_space *     f_mapping;            /*   232     8 =
*/
>=20
> I thought that each file really has to have a mapping. But the =
following
> should heal the issue and add an extra care.
>=20
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f64733c23067..fc9d70a9fbd1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -66,6 +66,8 @@ bool transparent_hugepage_enabled(struct =
vm_area_struct *vma)
> {
> 	if (vma_is_anonymous(vma))
> 		return __transparent_hugepage_enabled(vma);
> +	if (!vma->vm_file || !vma->vm_file->f_mapping)
> +		return false;
> 	if (shmem_mapping(vma->vm_file->f_mapping) && =
shmem_huge_enabled(vma))
> 		return __transparent_hugepage_enabled(vma);

=46rom what I see in code in mm/mmap.c, it seems if vma->vm_file is =
non-zero
vma->vm_file->f_mapping may be assumed to be non-NULL; see =
unlink_file_vma()
and __vma_link_file() for two examples, which both use the construct:

	file =3D vma->vm_file;
	if (file) {
		struct address_space *mapping =3D file->f_mapping;

		[ ... ]

		[ code that dereferences "mapping" without further =
checks ]
	}

I see nothing wrong with your second check but a few extra instructions
performed, but depending upon how often transparent_hugepage_enabled() =
is called
there may be at least theoretical performance concerns.

William Kucharski
william.kucharski@oracle.com
