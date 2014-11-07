Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE816B00D3
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 23:23:09 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so2779200wgh.29
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 20:23:08 -0800 (PST)
Subject: Re: [PATCH v5 7/7] add a flag for per-operation O_DSYNC semantics
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
From: Anton Altaparmakov <aia21@cam.ac.uk>
In-Reply-To: <x49r3xf28qn.fsf@segfault.boston.devel.redhat.com>
Date: Fri, 7 Nov 2014 06:22:48 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <BF30FAEC-D4D3-4079-9ECD-2743747279BD@cam.ac.uk>
References: <cover.1415220890.git.milosz@adfin.com> <cover.1415220890.git.milosz@adfin.com> <c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com> <x49r3xf28qn.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Milosz Tanski <milosz@adfin.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, Mel Gorman <mgorman@suse.de>, Volker Lendecke <Volker.Lendecke@sernet.de>, Tejun Heo <tj@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, linux-api@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-arch@vger.kernel.org, ceph-devel@vger.kernel.org, fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org

Hi Jeff,

> On 7 Nov 2014, at 01:46, Jeff Moyer <jmoyer@redhat.com> wrote:
>=20
> Milosz Tanski <milosz@adfin.com> writes:
>=20
>> -		if (type =3D=3D READ && (flags & RWF_NONBLOCK))
>> -			return -EAGAIN;
>> +		if (type =3D=3D READ) {
>> +			if (flags & RWF_NONBLOCK)
>> +				return -EAGAIN;
>> +		} else {
>> +			if (flags & RWF_DSYNC)
>> +				return -EINVAL;
>> +		}
>=20
> Minor nit, but I'd rather read something that looks like this:
>=20
> 	if (type =3D=3D READ && (flags & RWF_NONBLOCK))
> 		return -EAGAIN;
> 	else if (type =3D=3D WRITE && (flags & RWF_DSYNC))
> 		return -EINVAL;

But your version is less logically efficient for the case where "type =3D=3D=
 READ" is true and "flags & RWF_NONBLOCK" is false because your version =
then has to do the "if (type =3D=3D WRITE" check before discovering it =
does not need to take that branch either, whilst the original version =
does not have to do such a test at all.

Best regards,

	Anton

> I won't lose sleep over it, though.
>=20
> Reviewed-by: Jeff Moyer <jmoyer@redhat.com>

--=20
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
University of Cambridge Information Services, Roger Needham Building
7 JJ Thomson Avenue, Cambridge, CB3 0RB, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
