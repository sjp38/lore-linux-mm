Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 3F49C6B0078
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 18:39:14 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7158160pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 15:39:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339794567-17784-1-git-send-email-greg.pearson@hp.com>
References: <1339794567-17784-1-git-send-email-greg.pearson@hp.com>
Date: Fri, 15 Jun 2012 15:39:13 -0700
Message-ID: <CAE9FiQWGSDw7R2gbVYKfL6wmRVivaKhSALqXof1TsjgMNNf1hQ@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: fix overlapping allocation when doubling
 reserved array
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Pearson <greg.pearson@hp.com>
Cc: tj@kernel.org, hpa@linux.intel.com, akpm@linux-foundation.org, shangw@linux.vnet.ibm.com, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 15, 2012 at 2:09 PM, Greg Pearson <greg.pearson@hp.com> wrote:
> The __alloc_memory_core_early() routine will ask memblock for a range
> of memory then try to reserve it. If the reserved region array lacks
> space for the new range, memblock_double_array() is called to allocate
> more space for the array. If memblock is used to allocate memory for
> the new array it can end up using a range that overlaps with the range
> originally allocated in __alloc_memory_core_early(), leading to possible
> data corruption.
>
> @@ -399,7 +401,8 @@ repeat:
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (!insert) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (type->cnt + nr_new > type->max)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memblock_double_array(t=
ype) < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Avoid possible overlap i=
f range is being reserved */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memblock_double_array(t=
ype, base) < 0)

should use obase here.

Yinghai

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EN=
OMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0insert =3D true;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto repeat;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
