Received: from exch-staff1.ul.ie ([136.201.1.64])
 by ul.ie (PMDF V5.2-32 #41949) with ESMTP id <0GK000M36SK5ZD@ul.ie> for
 linux-mm@kvack.org; Fri, 21 Sep 2001 17:02:30 +0100 (BST)
Content-return: allowed
Date: Fri, 21 Sep 2001 17:07:34 +0100
From: "Gabriel.Leen" <Gabriel.Leen@ul.ie>
Subject: RE: Process not given >890MB on a 4MB machine ?????????
Message-id: <5D2F375D116BD111844C00609763076E050D1658@exch-staff1.ul.ie>
MIME-version: 1.0
Content-type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>, "'ebiederm@xmission.com'" <ebiederm@xmission.com>, "'tvignaud@mandrakesoft.com'" <tvignaud@mandrakesoft.com>
Cc: "Gabriel.Leen" <gabriel.leen@ul.ie>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'brian@worldcontrol.com'" <brian@worldcontrol.com>, "'arjan@fenrus.demon.nl'" <arjan@fenrus.demon.nl>
List-ID: <linux-mm.kvack.org>

Hello everybody,
Thanks for your help.

Unfortunately the package which I am using is a pre-compiled distribution,
so that limits what I can do with it :(
But I will hasle the developers and see what version of glibc they used.

QUESTION:
Have you actualy run a single process on the rawhide distribution which uses
~3GB ????????????
Please say YES :)

Red Hat kernel 2.4.9 as in 2.4.9-0.5 from rawhide ?
It should work, you should be able to get close to 3Gb....

++++++++++++++++++++++++++++++++++++++++++++++++++++
Some more info:
I have a small program listing attached which has helped me to identify the
problem.
It just gobbles up memory and writes zeros and f's to it

When I ran this on the kernel distribution out of the Box for Linux 7.1
delux
it would only work up to 1.2GB and then malloc returned NULL, continue
writing the
error messages to the console and eventually terminate normally.

Then I compiled the 2.4.9 kernel with the patch from Alan and it will run up
to 2GB
but not more, now the error occurs straight away when I hit run:
"segmentation fault"

Previously on the older kernel it would run when malloc returned NULL, the
program
continued writing the error and terminated normally.
Now the kernel appears to be psychic or something ?
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Thank you again for your help, much appreciated,
Gabriel


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#include <stdlib.h>

// Change SIZE for experiments
// size in MegaBytes.
#define SIZE 300

// Memory is allocated in SIZE  blocks of allocation units.
// currently all allocation units are stored in one array.
#define DEFAULT_BLOCK 1024
#define ALLOCATION_UNIT 1024

int main() {
        int c, i,j;
        char *ch;
        char *charray[SIZE*DEFAULT_BLOCK];

        for( i = 0; i < SIZE; i++ ) {
                for( c = 0; c < DEFAULT_BLOCK; c++ ) {
                        ch = malloc(ALLOCATION_UNIT);
                        if( ch == NULL )
                                printf("%d FAILED", c);
			charray[(i*DEFAULT_BLOCK)+c]=ch;

                }
                printf("%d\n", i);

                if( i % 10 == 0 )
                        sleep(1);
        }
	printf("writing 0x00-s to memory ...\n");
        for( i = 0; i < SIZE; i++ ) {
                for( c = 0; c < DEFAULT_BLOCK; c++ ) {
                	ch=charray[(i*DEFAULT_BLOCK)+c];
			for(j=0;j<ALLOCATION_UNIT;j++) {
				ch[j]=0x00;
			}
                }
                printf("%d\n", i);

                if( i % 10 == 0 )
                        sleep(1);
        }
	printf("writing 0xFF-s to memory ...\n");
        for( i = 0; i < SIZE; i++ ) {
                for( c = 0; c < DEFAULT_BLOCK; c++ ) {
                	ch=charray[(i*DEFAULT_BLOCK)+c];
			for(j=0;j<ALLOCATION_UNIT;j++) {
				ch[j]=0xFF;
			}
                }
                printf("%d\n", i);

                if( i % 10 == 0 )
                        sleep(1);
        }
	printf("Memory allocation succeeded. Total allocated memory in
kilobytes = %d\n",\

((DEFAULT_BLOCK*SIZE*ALLOCATION_UNIT)+sizeof(charray))/1024);
        printf("sleeping for 30 seconds ...\n");
        sleep(30);

        return 0;
}


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	END

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
