Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 0E8296B00E7
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:51:15 -0500 (EST)
Message-ID: <1329400247.2293.219.camel@twins>
Subject: Re: [PATCH 01/11] perf: Push file_update_time() into
 perf_mmap_fault()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 16 Feb 2012 14:50:47 +0100
In-Reply-To: <1329399979-3647-2-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
	 <1329399979-3647-2-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

On Thu, 2012-02-16 at 14:46 +0100, Jan Kara wrote:
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  kernel/events/core.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>=20
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index ba36013..61a67f3 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -3316,8 +3316,10 @@ static int perf_mmap_fault(struct vm_area_struct *=
vma, struct vm_fault *vmf)
>  	int ret =3D VM_FAULT_SIGBUS;
> =20
>  	if (vmf->flags & FAULT_FLAG_MKWRITE) {
> -		if (vmf->pgoff =3D=3D 0)
> +		if (vmf->pgoff =3D=3D 0) {
>  			ret =3D 0;
> +			file_update_time(vma->vm_file);
> +		}
>  		return ret;
>  	}

Its an anon filedesc, there's no actual file and while I guess one could
probably call fstat() on it, people really shouldn't care.

So feel free to introduce this patch to the bitbucket.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
