Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id ECC076B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 18:45:43 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so28738274qge.3
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 15:45:43 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id k3si13075731qch.17.2015.04.17.15.45.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 15:45:42 -0700 (PDT)
Received: by qkx62 with SMTP id 62so159023128qkx.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 15:45:41 -0700 (PDT)
Date: Fri, 17 Apr 2015 18:45:12 -0400
From: Michael Tirado <mtirado418@gmail.com>
Subject: Re: [PATCH] mm/shmem.c: Add new seal to memfd:
 F_SEAL_WRITE_NONCREATOR
Message-ID: <20150417184512.67015809@yak.slack>
In-Reply-To: <CANq1E4RebX=feEtgpHa4v_C_PkKwDmDWG+jm98kUUj5yYV4ipg@mail.gmail.com>
References: <20150416032316.00b79732@yak.slack>
	<CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
	<CANq1E4SbenR0-N4oLBMUe_2iiduU1TReA1RRTMA9_+h_mGwNOw@mail.gmail.com>
	<20150417002847.1f5febf7@yak.slack>
	<CANq1E4RebX=feEtgpHa4v_C_PkKwDmDWG+jm98kUUj5yYV4ipg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-mm@kvack.org

On Fri, 17 Apr 2015 12:48:44 +0200
David Herrmann <dh.herrmann@gmail.com> wrote:

> Where's the problem? Just pass the read-only file-descriptor to your
> peers and make sure the access-mode of the memfd is 0600. No other
> user will be able to gain a writable file-descriptor, but you.

I see what you mean now, This does make sense. I started writing a test
and it seems like the write on a duplicated O_RDONLY fd  does not fail
properly,  and is causing a general protection error.  Here is the output
and test code:


memfd: a dup test
expected EPERM on write(), but got 4: Operation not permitted
back in main thread
[    8.563759] traps: memfd_test[548] general protection ip:b75b638c sp:bffdbbe0 error:0 in libc-2.20.so[b7589000+1ae000]
bash-4.3# 

note that the return value 4 indicates successful write.



static void test_dup()
{
	pid_t pid;
	int status;
	int fd_seal;
	int fd_rdonly = 99;

	fd_seal = mfd_assert_new("kern_memfd_seal_write",
					MFD_DEF_SIZE,
					MFD_CLOEXEC | MFD_ALLOW_SEALING);

	fd_rdonly = dup3(fd_seal, fd_rdonly, O_RDONLY);
	mfd_assert_add_seals(fd_seal, F_SEAL_SEAL);
	if (fd_rdonly != 99) {
		printf("dup3 error: %m\n");
		abort();
	}

	pid = fork();
	if (pid == 0)
	{
		int fd_peer = 97;
		
		/*mfd_fail_write(fd_seal);*/
		/* this does not fail properly? */
		mfd_fail_write(fd_rdonly);
		
		/* this will fail with, invalid argument */
		/*fd_peer = dup3(fd_rdonly, fd_peer, O_RDWR);
		if (fd_peer == -1) {
			printf("dup3 error: %m\n");
			abort();
		}
		mfd_fail_write(fd_peer);*/
		printf("exiting normally\n");
		exit(0);
	}

	usleep(100000);
	printf("back in main thread\n");
	mfd_assert_write(fd_seal);
	/*mfd_fail_write(fd_rdonly);*/
	usleep(1000000);
	
	/* this seems to trigger general protection crash */
	pid = waitpid(pid, &status, 0);
	if (!WIFEXITED(status))
		abort();
}


I don't have time right now to dig deep into this, but will look into it more
in the next few days,  and report back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
