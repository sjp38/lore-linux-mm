Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 002876B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:51:19 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so11709342wme.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 20:51:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d28si629140wma.147.2017.01.12.20.51.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 20:51:18 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Fri, 13 Jan 2017 15:51:09 +1100
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <20170111114023.GA4813@noname.redhat.com>
References: <20170110160224.GC6179@noname.redhat.com> <20170111050356.ldlx73n66zjdkh6i@thunk.org> <20170111114023.GA4813@noname.redhat.com>
Message-ID: <87y3yfftqa.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Wolf <kwolf@redhat.com>, Theodore Ts'o <tytso@mit.edu>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 11 2017, Kevin Wolf wrote:

> Am 11.01.2017 um 06:03 hat Theodore Ts'o geschrieben:
>> A couple of thoughts.
>>=20
>> First of all, one of the reasons why this probably hasn't been
>> addressed for so long is because programs who really care about issues
>> like this tend to use Direct I/O, and don't use the page cache at all.
>> And perhaps this is an option open to qemu as well?
>
> For our immediate case, yes, O_DIRECT can be enabled as an option in
> qemu, and it is generally recommended to do that at least for long-lived
> VMs. For other cases it might be nice to use the cache e.g. for quicker
> startup, but those might be cases where error recovery isn't as
> important.
>
> I just see a much broader problem here than just for qemu. Essentially
> this approach would mean that every program that cares about the state
> it sees being safe on disk after a successful fsync() would have to use
> O_DIRECT. I'm not sure if that's what we want.

This is not correct.  If an application has exclusive write access to a
file (which is common, even if only enforced by convention) and if that
program checks the return of every write() and every fsync() (which, for
example, stdio does, allowing ferror() to report if there have ever been
errors), then it will know if its data if safe.

If any of these writes returned an error, then there is NOTHING IT CAN
DO about that file.  It should be considered to be toast.
If there is a separate filesystem it can use, then maybe there is a way
forward, but normally it would just report an error in whatever way is
appropriate.

My position on this is primarily that if you get a single write error,
then you cannot trust anything any more.
You suggested before that NFS problems can cause errors which can be
fixed by the sysadmin so subsequent writes succeed.  I disagreed - NFS
will block, not return an error.  Your last paragraph below indicates
that you agree.  So I ask again: can you provide a genuine example of a
case where a write might result in an error, but that sysadmin
involvement can allow a subsequent attempt to write to succeed.   I
don't think you can, but I'm open...

I note that ext4 has an option "errors=3Dremount-ro".  I think that
actually makes a lot of sense.  I could easily see an argument for
supporting this at the file level, when it isn't enabled at the
filesystem level. If there is any write error, then all subsequent
writes should cause an error, only reads should be allowed.

Thanks,
NeilBrown


>
>> Secondly, one of the reasons why we mark the page clean is because we
>> didn't want a failing disk to memory to be trapped with no way of
>> releasing the pages.  For example, if a user plugs in a USB
>> thumbstick, writes to it, and then rudely yanks it out before all of
>> the pages have been writeback, it would be unfortunate if the dirty
>> pages can only be released by rebooting the system.
>
> Yes, I understand that and permanent failure is definitely a case to
> consider while making any changes. That's why I suggested to still allow
> releasing such pages, but at a lower priority than actually clean pages.
> And of course, after losing data, an fsync() may never succeed again on
> a file descriptor that was open when the data was thrown away.
>
>> So an approach that might work is fsync() will keep the pages dirty
>> --- but only while the file descriptor is open.  This could either be
>> the default behavior, or something that has to be specifically
>> requested via fcntl(2).  That way, as soon as the process exits (at
>> which point it will be too late for it do anything to save the
>> contents of the file) we also release the memory.  And if the process
>> gets OOM killed, again, the right thing happens.  But if the process
>> wants to take emergency measures to write the file somewhere else, it
>> knows that the pages won't get lost until the file gets closed.
>
> This sounds more or less like what I had in mind, so I agree.
>
> The fcntl() flag is an interesting thought, too, but would there be
> any situation where the userspace would have an advantage from not
> requesting the flag?
>
>> (BTW, a process could guarantee this today without any kernel changes
>> by mmap'ing the whole file and mlock'ing the pages that it had
>> modified.  That way, even if there is an I/O error and the fsync
>> causes the pages to be marked clean, the pages wouldn't go away.
>> However, this is really a hack, and it would probably be easier for
>> the process to use Direct I/O instead.  :-)
>
> That, and even if the pages would still in memory, as I understand it,
> the writeout would never be retried because they are still marked clean.
> So it wouldn't be usable for a temporary failure, but only for reading
> the data back from the cache into a different file.
>
>> Finally, if the kernel knows that an error might be one that could be
>> resolved by the simple expedient of waiting (for example, if a fibre
>> channel cable is temporarily unplugged so it can be rerouted, but the
>> user might plug it back in a minute or two later, or a dm-thin device
>> is full, but the system administrator might do something to fix it),
>> in the ideal world, the kernel should deal with it without requiring
>> any magic from userspace applications.  There might be a helper system
>> daemon that enacts policy (we've paged the sysadmin, so it's OK to
>> keep the page dirty and retry the writebacks to the dm-thin volume
>> after the helper daemon gives the all-clear), but we shouldn't require
>> all user space applications to have magic, Linux-specific retry code.
>
> Yes and no. I agree that the kernel should mostly make things just work.
> We're talking about a relatively obscure error case here, so if
> userspace applications have to do something extraordinary, chances are
> they won't be doing it.
>
> On the other hand, indefinitely blocking on fsync() isn't really what we
> want either, so while the kernel should keep trying to get the data
> written in the background, a failing fsync() would be okay, as long as a
> succeeding fsync() afterwards means that we're fully consistent again.
>
> In qemu, indefinitely blocking read/write syscalls are already a problem
> (on NFS), because instead of getting an error and then stopping the VM,
> the request hangs so long that the guest kernel sees a timeout and
> offlines the disk anyway. But that's a separate problem...
>
> Kevin
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlh4XL0ACgkQOeye3VZi
gbmZhxAAqBMAJJst7dY+fVFWLpVlGDkobjT7HfP2GwqkQTC/tw1BxJ2RWWxlNJc6
Vv2JK/mI2nfMGFS17pgYr32uyUgTRdl4ZvifJZugq2ek00jERcbJ5creI58RVaIV
KFHFrxpUsb35BrLPd1mx2mthjkXvE9st8t8AO42pC3ilI8r5OE+p+XVR7v3qubfP
8SsX0K3mBp5vtZpsBJXpaZ3rzVhT8ivg+PKIU5wrIIQU6HYKA3xrFYSgxRW0CBEs
bHMsIatS/j3exHkoSPt78pn/p53o738fDYLRQU2/DsMYZvxUL86UiQB7QDWvngph
7CtTQTj/rZlW/1jBg68hNQWofICPruf9CzFXXI6ibQY1luqsvlDZOcXa/capqxWa
AkQxRSTcCphrYisVM8Z9RwCWbdMCp54XhEawPW33hdHZMrNO+WHqARLB7f+LiCHq
S3VXWKocGqqp5j8+B7QluuS5c+X0N+ybH4Ta3PExl+jmeFsa+BMAv1oYlfgBpRPu
eYjDwaY8hnPaxc5Zdpfr66aZ8BNKgimV8SFcs2LMFYpy918fXntz304oUZ2mkCVM
YR/yTbfxdqRL4Bo05JGAQxV02c6lPl34TcuetMf9C2u4dOinS3EAeM1N3FKDM33t
Tsftj3Znyrjz5GS3rymebBMmUNoCvI7dpArazB6sqwdxukpy24U=
=NDYg
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
