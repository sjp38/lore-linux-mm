Received: from northrelay04.pok.ibm.com (northrelay04.pok.ibm.com [9.56.224.206])
	by e6.ny.us.ibm.com (8.12.2/8.12.2) with ESMTP id g99IffDn009054
	for <linux-mm@kvack.org>; Wed, 9 Oct 2002 14:41:41 -0400
Received: from localhost.localdomain (plars.austin.ibm.com [9.53.216.72])
	by northrelay04.pok.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id g99IfcRT081514
	for <linux-mm@kvack.org>; Wed, 9 Oct 2002 14:41:38 -0400
Subject: Hangs in 2.5.41-mm1
From: Paul Larson <plars@linuxtestproject.org>
Content-Type: multipart/mixed; boundary="=-Zt66PqqXBt0KqwC5fF1+"
Date: 09 Oct 2002 13:36:13 -0500
Message-Id: <1034188573.30975.40.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-Zt66PqqXBt0KqwC5fF1+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I'm able to generate a lot of hangs with 2.5.41-mm1.
This is on a 8-way PIII-700, 16 GB ram (PAE enabled)

The first one, I got by running ltp for a while, then the attached test
for a bit, then, at the suggestion of Bill Irwin to increase the amount
of ram I could be using for huge pages:
echo 768 > /proc/sys/vm/nr_hugepages

Doing that (and the corresponding echo 1610612736 >
/proc/sys/kernel/shmmax) after a cold boot gave me no problems though.

I also got it to hang after runnging the attached test with -s
1610612736 and then running another one with no options.

There was no output on the serial console when it hung, and it was
unresponsive to ping, vc switch, and sysrq.

The attached test is an ltp shmem test modified by Bill Irwin to support
the shm huge pages in 2.5.41-mm1.  Compile it with --static.

Thanks,
Paul Larson



--=-Zt66PqqXBt0KqwC5fF1+
Content-Disposition: attachment; filename=shmt01.c
Content-Transfer-Encoding: quoted-printable
Content-Type: text/x-c; name=shmt01.c; charset=ISO-8859-1

/*
 *
 *   Copyright (c) International Business Machines  Corp., 2001
 *
 *   This program is free software;  you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY;  without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
 *   the GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program;  if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 US=
A
 */

/*
 * Copyright (C) Bull S.A. 1996
 * Level 1,5 Years Bull Confidential and Proprietary Information
 */

/*---------------------------------------------------------------------+
|                           shmem_test_01                              |
| =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D |
|                                                                      |
| Description:  Simplistic test to verify the shmem system function    |
|               calls.                                                 |
|                                                                      |
|                                                                      |
| Algorithm:    o  Obtain a unique shared memory identifier with       |
|                  shmget ()                                           |
|               o  Map the shared memory segment to the current        |
|                  process with shmat ()                               |
|               o  Index through the shared memory segment             |
|               o  Release the shared memory segment with shmctl ()    |
|                                                                      |
| System calls: The following system calls are tested:                 |
|                                                                      |
|               shmget () - Gets shared memory segments                |
|               shmat () - Controls shared memory operations           |
|               shmctl () - Attaches a shared memory segment or mapped |
|                           file to the current process                |
|                                                                      |
| Usage:        shmem_test_01                                          |
|                                                                      |
| To compile:   cc -o shmem_test_01 shmem_test_01.c                    |
|                                                                      |
| Last update:   Ver. 1.2, 2/8/94 00:08:30                           |
|                                                                      |
| Change Activity                                                      |
|                                                                      |
|   Version  Date    Name  Reason                                      |
|    0.1     111593  DJK   Initial version for AIX 4.1                 |
|    1.2     020794  DJK   Moved to "prod" directory                   |
|                                                                      |
+---------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/shm.h>

/* Defines
 *
 * MAX_SHMEM_SIZE: maximum shared memory segment size of 256MB=20
 * (reference 3.2.5 man pages)
 *
 * DEFAULT_SHMEM_SIZE: default shared memory size, unless specified with
 * -s command line option
 *=20
 * SHMEM_MODE: shared memory access permissions (permit process to read
 * and write access)
 *=20
 * USAGE: usage statement
 */
#define SHM_HUGETLB		04000
#define SHMADDR			((const void *)0x4000000)
#define MAX_SHMEM_SIZE		(3UL*1024UL*1024UL*1024UL)
#define DEFAULT_SHMEM_SIZE	(64*1024*1024)
#define	SHMEM_MODE		(SHM_R | SHM_W | SHM_HUGETLB | IPC_CREAT)
#define USAGE	"\nUsage: %s [-s shmem_size]\n\n" \
		"\t-s shmem_size  size of shared memory segment (bytes)\n" \
		"\t               (must be less than 256MB!)\n\n"

/*
 * Function prototypes
 *
 * parse_args (): Parse command line arguments
 * sys_error (): System error message function
 * error (): Error message function
 */
void parse_args (int, char **);
void sys_error (const char *, int);
void error (const char *, int);

/*
 * Global variables
 *=20
 * shmem_size: shared memory segment size (in bytes)
 */
unsigned long shmem_size =3D DEFAULT_SHMEM_SIZE;
const key_t key =3D 1;

/*---------------------------------------------------------------------+
|                               main                                   |
| =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D |
|                                                                      |
|                                                                      |
| Function:  Main program  (see prolog for more details)               |
|                                                                      |
| Returns:   (0)  Successful completion                                |
|            (-1) Error occurred                                       |
|                                                                      |
+---------------------------------------------------------------------*/
int main (int argc, char **argv)
{
	int	shmid;		/* (Unique) Shared memory identifier */
	char	*shmptr,	/* Shared memory segment address */
		*ptr,		/* Index into shared memory segment */
		value =3D 0;	/* Value written into shared memory segment */

	/*
	 * Parse command line arguments and print out program header
	 */
	parse_args (argc, argv);
	printf ("%s: IPC Shared Memory TestSuite program\n", *argv);
   =20
	/*
	 * Obtain a unique shared memory identifier with shmget ().
	 * Attach the shared memory segment to the process with shmat (),=20
	 * index through the shared memory segment, and then release the
	 * shared memory segment with shmctl ().
	 */
	printf ("\n\tGet shared memory segment (%lu bytes)\n", shmem_size);
	if ((shmid =3D shmget (key, shmem_size, SHMEM_MODE)) < 0)
		sys_error ("shmget failed", __LINE__);

	printf ("\n\tAttach shared memory segment to process\n");
	if ((shmptr =3D shmat (shmid, SHMADDR, SHM_HUGETLB)) < 0)
		sys_error ("shmat failed", __LINE__);

	printf ("\n\tIndex through shared memory segment ...\n");
	for (ptr=3Dshmptr; ptr < (shmptr + shmem_size); ptr++)
		*ptr =3D value++;
	sleep(10);

	printf ("\n\tRelease shared memory\n");
	if (shmctl (shmid, IPC_RMID, 0) < 0)
		sys_error ("shmctl failed", __LINE__);

	/*=20
	 * Program completed successfully -- exit
	 */
	printf ("\nsuccessful!\n");

	return (0);
}


/*---------------------------------------------------------------------+
|                             parse_args ()                            |
| =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D |
|                                                                      |
| Function:  Parse the command line arguments & initialize global      |
|            variables.                                                |
|                                                                      |
| Updates:   (command line options)                                    |
|                                                                      |
|            [-s] size: shared memory segment size                     |
|                                                                      |
+---------------------------------------------------------------------*/
void parse_args (int argc, char **argv)
{
	int	i;
	int	errflag =3D 0;
	char	*program_name =3D *argv;
	extern char 	*optarg;	/* Command line option */

	while ((i =3D getopt(argc, argv, "s:?")) !=3D EOF) {
		switch (i) {
			case 's':
				shmem_size =3D atoi (optarg);
				break;
			case '?':
				errflag++;
				break;
		}
	}

	if (shmem_size < 1 || shmem_size > MAX_SHMEM_SIZE)
		errflag++;

	if (errflag) {
		fprintf (stderr, USAGE, program_name);
		exit (2);
	}
}


/*---------------------------------------------------------------------+
|                             sys_error ()                             |
| =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D |
|                                                                      |
| Function:  Creates system error message and calls error ()           |
|                                                                      |
+---------------------------------------------------------------------*/
void sys_error (const char *msg, int line)
{
	char syserr_msg [256];

	sprintf (syserr_msg, "%s: %s\n", msg, strerror (errno));
	error (syserr_msg, line);
}


/*---------------------------------------------------------------------+
|                               error ()                               |
| =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D |
|                                                                      |
| Function:  Prints out message and exits...                           |
|                                                                      |
+---------------------------------------------------------------------*/
void error (const char *msg, int line)
{
	fprintf (stderr, "ERROR [line: %d] %s\n", line, msg);
	exit (-1);
}

--=-Zt66PqqXBt0KqwC5fF1+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
