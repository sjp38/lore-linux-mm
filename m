Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C82D56B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 22:16:45 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n187so3923813pfn.10
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:16:45 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id w125si2299639pgb.296.2017.11.29.19.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 19:16:44 -0800 (PST)
Subject: Re: [PATCH] mmap.2: document new MAP_FIXED_SAFE flag
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144524.23518-1-mhocko@kernel.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <593899ff-08ad-6c3f-d69d-346f6bc5d1f6@nvidia.com>
Date: Wed, 29 Nov 2017 19:16:39 -0800
MIME-Version: 1.0
In-Reply-To: <20171129144524.23518-1-mhocko@kernel.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, Michal Hocko <mhocko@suse.com>

On 11/29/2017 06:45 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 4.16+ kernels offer a new MAP_FIXED_SAFE flag which allows to atomicaly

"allows the caller to atomically"

, if you care about polishing the commit message...see the real review,
below. :)

> probe for a given address range.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  man2/mmap.2 | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 385f3bfd5393..622a7000de83 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -225,6 +225,18 @@ will fail.
>  Because requiring a fixed address for a mapping is less portable,
>  the use of this option is discouraged.
>  .TP
> +.B MAP_FIXED_SAFE (since 4.16)
> +Similar to MAP_FIXED wrt. to the
> +.I
> +addr
> +enforcement except it never clobbers a colliding mapped range and rather fail with
> +.B EEXIST
> +in such a case. This flag can therefore be used as a safe and atomic probe for the
> +the specific address range. Please note that older kernels which do not recognize
> +this flag can fallback to the hint based implementation and map to a different
> +location. Any backward compatible software should therefore check the returning
> +address with the given one.
> +.TP
>  .B MAP_GROWSDOWN
>  This flag is used for stacks.
>  It indicates to the kernel virtual memory system that the mapping

Hi Michal,

I've taken the liberty of mostly rewriting this part, in order to more closely 
match the existing paragraphs; to fix minor typos; and to attempt to slightly
clarify the paragraph.

+.BR MAP_FIXED_SAFE " (since Linux 4.16)"
+Similar to MAP_FIXED with respect to the
+.I
+addr
+enforcement, but different in that MAP_FIXED_SAFE never clobbers a pre-existing
+mapped range. If the requested range would collide with an existing
+mapping, then this call fails with
+.B EEXIST.
+This flag can therefore be used as a way to atomically (with respect to other
+threads) attempt to map an address range: one thread will succeed; all others
+will report failure. Please note that older kernels which do not recognize this
+flag will typically (upon detecting a collision with a pre-existing mapping)
+fall back a "non-MAP_FIXED" type of behavior: they will return an address that
+is different than the requested one. Therefore, backward-compatible software
+should check the returned address against the requested address.
+.TP

(I'm ignoring the naming, because there is another thread about that,
so please just the above as "MAP_FIXED_whatever-is-chosen".)

> @@ -449,6 +461,12 @@ is not a valid file descriptor (and
>  .B MAP_ANONYMOUS
>  was not set).
>  .TP
> +.B EEXIST
> +range covered by
> +.IR addr , 

nit: trailing space on the above line.

> +.IR length
> +is clashing with an existing mapping.
> +.TP
>  .B EINVAL
>  We don't like
>  .IR addr ,
> 

One other thing: reading through mmap.2, I now want to add this as well:

diff --git a/man2/mmap.2 b/man2/mmap.2
index 622a7000d..780cad6d9 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -222,20 +222,25 @@ part of the existing mapping(s) will be discarded.
 If the specified address cannot be used,
 .BR mmap ()
 will fail.
-Because requiring a fixed address for a mapping is less portable,
-the use of this option is discouraged.
+Software that aspires to be as portable as possible should use this option with
+care, keeping in mind that different kernels and C libraries may set up quite
+different mapping ranges.


...because that advice is just wrong (it presumes that "less portable" ==
"must be discouraged").

Should I send out a separate patch for that, or is it better to glom it together 
with this one?

thanks,
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
