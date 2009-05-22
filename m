Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 924C16B004D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 15:18:28 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so931209yxh.26
        for <linux-mm@kvack.org>; Fri, 22 May 2009 12:18:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090522180351.GC13971@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	 <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu>
	 <20090522113809.GB13971@oblivion.subreption.com>
	 <20090522143914.2019dd47@lxorguk.ukuu.org.uk>
	 <20090522180351.GC13971@oblivion.subreption.com>
Date: Sat, 23 May 2009 03:18:44 +0800
Message-ID: <ab418ea90905221218u54fc70eje5be902f1e8109b9@mail.gmail.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Sat, May 23, 2009 at 2:03 AM, Larry H. <research@subreption.com> wrote:
> On 14:39 Fri 22 May =A0 =A0 , Alan Cox wrote:
>> > > performance point of view: we _dont_ want to clear the full stack
>> > > page for every kernel thread exiting.
>> >
>> > Burning the stack there is beyond overkill.
>>
>> Yet most of our historic leaks have been padding bytes in stack based
>> structures. Your position seems very inconsistent.
>
> Alright, I think I had enough of the theoretical mumbo jumbo, with all
> due respect. Let's get on with the show.
>
> I'm going to present a very short analysis for different historic leaks
> which had little to do with 'padding bytes in stack', but more like
> arbitrary kernel memory leaked to userland, or written to disk, or sent
> over the network. If by the end of this message you still
> believe my position is remotely inconsistent, I'll have to politely
> request you to back it up with something that can be technically and
> empirically proven from both programmer and security perspectives.
>
> 1. CVE-2005-0400 aka the infamous ext2_make_empty() disaster
> (http://arkoon.net/advisories/ext2-make-empty-leak.txt)
>
> The ext2 code before 2.6.11.6 was affected by an uninitialized variable
> usage vulnerability which lead to 4072 bytes worth of kernel memory
> being leaked to disk, when creating a block for a new directory entry.
> The affected function was ext2_make_empty() and it was fixed by adding a
> memset call to zero the memory.
>
> http://lxr.linux.no/linux+v2.6.12/fs/ext2/dir.c#L578
>
> =A0594 =A0 =A0 =A0 =A0kaddr =3D kmap_atomic(page, KM_USER0);
> =A0595 =A0 =A0 =A0 memset(kaddr, 0, chunk_size);
> =A0596 =A0 =A0 =A0 =A0de =3D (struct ext2_dir_entry_2 *)kaddr;
> =A0597 =A0 =A0 =A0 =A0de->name_len =3D 1;
> =A0598 =A0 =A0 =A0 =A0de->rec_len =3D cpu_to_le16(EXT2_DIR_REC_LEN(1));
>
> http://lxr.linux.no/linux-bk+v2.6.11.5/fs/ext2/dir.c#L578
>
> =A0594 =A0 =A0 =A0 =A0kaddr =3D kmap_atomic(page, KM_USER0);
> =A0595 =A0 =A0 =A0 =A0de =3D (struct ext2_dir_entry_2 *)kaddr;
> =A0596 =A0 =A0 =A0 =A0de->name_len =3D 1;
> =A0597 =A0 =A0 =A0 =A0de->rec_len =3D cpu_to_le16(EXT2_DIR_REC_LEN(1));
> =A0598 =A0 =A0 =A0 =A0memcpy (de->name, ".\0\0", 4);
>
> An atomic call to kmap(). This lead to widespread searching for online
> ext2 images and general hilarity. And it was a longstanding issue in
> the kernel, too.
>
> 2. CVE-2009-0787 aka ecryptfs_write_metadata_to_contents() leak
> (commit 8faece5f906725c10e7a1f6caf84452abadbdc7b)
>
> The ecryptfs function ecryptfs_write_metadata_to_contents() leaked up to
> an entire page to userland. An incorrect size was used during the copy
> operation, leading to more bytes being copied, hence the leak.
>
> + =A0 =A0 =A0 virt_len =3D crypt_stat->num_header_bytes_at_front;
> + =A0 =A0 =A0 order =3D get_order(virt_len);
> =A0 =A0 =A0 =A0/* Released in this function */
> - =A0 =A0 =A0 virt =3D (char *)get_zeroed_page(GFP_KERNEL);
> + =A0 =A0 =A0 virt =3D (char *)ecryptfs_get_zeroed_pages(GFP_KERNEL,
> =A0 =A0 =A0 =A0order);
>
> 3. CVE-2002-0046 aka information leak over ICMP TTL Exceeded responses
> (http://archives.neohapsis.com/archives/bugtraq/2002-01/0234.html)
> (http://rhn.redhat.com/errata/RHSA-2002-007.html)
>
> Series of fragmented ICMP packets that generate an ICMP TTL
> Exceeded response would include 20 bytes of arbitrary kernel memory,
> sent back to the attacker. I didn't bother digging for the patch. But
> you bet it has to do with kmallocated skb buffers (take a look at
> http://lxr.linux.no/linux-old+v2.2.16/net/ipv4/ipip.c#L436).
>
> 4. CVE-2007-6417 aka shmem_getpage() tmpfs leak
> (http://marc.info/?l=3Dlinux-kernel&amp;m=3D119627664702379&amp;w=3D2)
>
> An issue related with tmpfs, users were able to obtain kernel memory
> because the shmem_getpage() didn't always zero the memory when reusing
> an allocated page. The vulnerability was present from 2.6.11 through
> 2.6.23.
>
> @@ -1306,6 +1306,7 @@ repeat:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->alloced++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&info->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_highpage(filepage);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flush_dcache_page(filepage);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageUptodate(filepage);
> =A0 =A0 =A0 =A0}
>
> If the caller provided the page already allocated, the GFP_ZERO
> allocation never happened, and the page was never cleared. Interesting
> issue since my patch basically ensures this doesn't happen. Nevermind.
>
> 5. CVE-2008-4113 aka sctp_getsockopt_hmac_ident() leak (< 2.6.26.4)
> (commit d97240552cd98c4b07322f30f66fd9c3ba4171de)
> (exploit by Jon Oberheide at http://www.milw0rm.com/exploits/7618)
>
> In kernels before 2.6.26.4 with SCTP and the SCTP-AUTH extension
> enabled, an unprivileged local can leak arbitrary kernel memory abusing
> an unbounded (due to incorrect length check) copy in the
> sctp_getsockopt_hmac_ident() function. The data copied comes from a
> kmallocated object (the struct sctp_association *asoc). This could be
> exploited with a SCTP_HMAC_IDENT IOCTL request (through sctp_getsockopt).
>
> From the exploit:
> =A0* =A0 If SCTP AUTH is enabled (net.sctp.auth_enable =3D 1), this explo=
it
> =A0* =A0 allow an =A0unprivileged user to dump an arbitrary amount (DUMP_=
SIZE) of
> =A0* =A0 kernel memory out to a file (DUMP_FILE). If SCTP AUTH is not ena=
bled, the
> =A0* =A0 exploit will trigger a kernel OOPS.
>
> It's worth noting that the commit title and description don't reveal the
> true nature of the bug (a perfectly exploitable vulnerability, platform
> independent like most other information leaks):
> "sctp: fix random memory dereference with SCTP_HMAC_IDENT option."
>
> At least it's not entirely deceitful. It's definitely dereferencing
> "random memory".
>
> 6. CVE-2007-1000 aka ipv6_getsockopt_sticky() leak (<2.6.20.2)
> (http://bugzilla.kernel.org/show_bug.cgi?id=3D8134)
> (commit 286930797d74b2c9a5beae84836044f6a836235f)
> (exploit at http://www.milw0rm.com/exploits/4172)
>
> The bug was initially assumed to be a simple NULL pointer dereference by
> Chris Wright... but since kernel and userland address space coexist in
> x86 and other architectures, this is an exploitable condition which
> was used to leak kernel memory to userland after a page was allocated at
> NULL by the exploit abusing the issue.
>

As we all can see from these CVEs, in order to fix them,
data can be zeroed at two points:
1. zero allocated pages that can leak to user
2. zero sensitive pages when they are recycled

Your patch chooses the latter.
But problem still remains, that is how to judge a page is sensitive  or not=
?
I wonder if all of the developer can always make successful judgement.
Any kernel data/meta data can be sensitive, and that also depends on how
the exploit code will use it.  So we just blindly flag them all ?

While it's comparatively much easier to track if a page will go to user.
So why not adopt the 1. time point to zero pages?

> -
>
> Further examples could be found in the commit logs or mining other places=
.
> Also, this is the tip of the iceberg. Whatever is lurking deep inside the
> kernel sources right now will only be deterred with my patch and any futu=
re
> modifications that cover corner cases.
>
> The following file contains a list of CVE numbers correlated with
> commits, which comes handy to look for more examples:
> http://web.mit.edu/tabbott/www/cve-data/cve-data.txt
>
> I've saved a backup copy in case it goes offline and will put it
> somewhere accessible for people on the list in such a case.
>
> My intention here is to make the kernel more secure, not proving you
> wrong or right.
>
> You are a smart fellow and I respect your technical and kernel developmen=
t
> acumen. Smart people don't waste their time on meaningless banter.
>
> I'll have the modified patches ready in an hour or so, hopefully.
>
> =A0 =A0 =A0 =A0Larry
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
