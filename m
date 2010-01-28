Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A522C6B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 02:34:34 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so515789fgg.8
        for <linux-mm@kvack.org>; Wed, 27 Jan 2010 23:34:31 -0800 (PST)
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-25-741517454"
Message-Id: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com>
From: Mathias Krause <minipli@googlemail.com>
Subject: DoS on x86_64
Date: Thu, 28 Jan 2010 08:34:02 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
Cc: security@kernel.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-25-741517454
Content-Type: multipart/mixed; boundary=Apple-Mail-24-741517396


--Apple-Mail-24-741517396
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed

Hello security team,

I found by accident an reliable way to panic the kernel on an x86_64  
system. Since this one can be triggered by an unprivileged user I  
CCed security@kernel.org. I also haven't found a corresponding bug on  
bugzilla.kernel.org. So, what to do to trigger the bug:

1. Enable core dumps
2. Start an 32 bit program that tries to execve() an 64 bit program
3. The 64 bit program cannot be started by the kernel because it  
can't find the interpreter, i.e. execve returns with an error
4. Generate a segmentation fault
5. panic

The problem seams to be located in fs/binfmt_elf.c:load_elf_binary().  
It calls SET_PERSONALITY() prior checking that the ELF interpreter is  
available. This in turn makes the previously 32 bit process a 64 bit  
one which would be fine if execve() would succeed. But after the  
SET_PERSONALITY() the open_exec() call fails (because it cannot find  
the interpreter) and execve() almost instantly returns with an error.  
If you now look at /proc/PID/maps you'll see, that it has the  
vsyscall page mapped which shouldn't be. But the process is not dead  
yet, it's still running. By now generating a segmentation fault and  
in turn trying to generate a core dump the kernel just dies. I  
haven't yet looked into this code but maybe you guys are much faster  
than me and just can fix this problem :)

Test case for this bug is attached. It was tested on a 2.6.26.7 and  
2.6.30.10, but I may affect even older kernels. So it may be  
interesting for stable, too.


Greetings,
Mathias Krause
--Apple-Mail-24-741517396
Content-Transfer-Encoding: base64
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name=amd64_killer.tgz
Content-Disposition: attachment;
	filename=amd64_killer.tgz

H4sIANGvYEsAA+2WW0/bMBSA+0p+xYGpkFRtLm1aJAqTpmkPaJuY0KRt2lDlOm5rNXEq2+moBv99
xymlDTDYAxdN8/cS5/j4XB07JEt68WDK05TJoPY0hMh+t7t89qrPK2pR1OmEUXu/0w5r+Ozsd2vQ
faJ4KhRKEwlQy6b36z00v0pk9fxHIJv933zx6aP5MPXoxfGf+t+O4o3+R6gXdcOoV4NnKeJ/3v9X
XNC0SBgcqoUKJFN5ISnzJ6+d6oxezJi6Q8yzO5SxpNpIN8SF4EonN1R1kvLhTZnkYnxLj+dVEZNS
lCLH4UJDRrhwzYDIMW0CnWBLGw18mV+/MDGfefDL2UIPBdUgU55xDTSXbFAO+46zxUfgjplezrmn
H44/Hn8evD05fdeE3bWmB9tHEJbGtmYYSS7dnfUqb8fr4wQ7x3FkhpdXhtcGfKM6oIWEo7UhzFuP
3J1PKSOKARNkmLIyPEiKbKYAFXIJ7JzRQmOJQE+4EeZjSTL/h1h6XVn5lhdAiYAkB5XDcLGxblRa
IdkMze8Vyyq0KERhO95bmbkdvCksHEIbLi6AUMqUMqL59+isCV8HJ++9ahaFImN2AHUFvXjI9cDE
icabUC4Kz+7wslragDTPp0A0BLiKBvUkyAjmT0SC6aJjrI1mEnSO1RGYUsF830fT2IIZT1zPGPw5
4Zie6aVpv1t2DLPb89Btv+JsXZi6QjvrIKMySDM9Z+tcd69H5Ybqb5rSEwx6RNBzAm5deWgIgz2f
MapRcuCVtnH7LbdMuYVNsC+W+ogozQQs8JMHxdDrkKXaGBNMkrIkio0zdIkvuUD1ItXLEhk/DXf5
ZXkQnsf7UQTo5s2e8SCZLqSAsO9cOi99vlnup3L/y0L4avLoPh76/2vH3dX930Pw/u90Ud3e/8/A
q+1gyEWgJo4zphRaWacNrRw2twVUfwvhSrEXQ+tL2my1koUgGaetlIspk81A5KKFR7s5W7SPtw+a
m+Vc4Qly01D19nH8yg8o+MHVMnuIWCwWi8VisVgsFovFYrFYLBaLxWKxWCx/x28dR5RHACgAAA==

--Apple-Mail-24-741517396--

--Apple-Mail-25-741517454
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (Darwin)

iD8DBQFLYT3qZS2uZ5iBxS8RAlkuAJ0Z6sRcp0EugNbzBSSuNVa6BEIRdgCg5qbJ
aVoW/AaM2gT3/QO1KcuGk7s=
=/aZl
-----END PGP SIGNATURE-----

--Apple-Mail-25-741517454--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
