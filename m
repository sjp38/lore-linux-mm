Subject: Re: Fixing private mappings
References: <Pine.LNX.3.95.980423105842.15346A-100000@as200.spellcast.com>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 23 Apr 1998 17:03:02 -0500
In-Reply-To: "Benjamin C.R. LaHaise"'s message of Thu, 23 Apr 1998 11:12:12 -0400 (EDT)
Message-ID: <m1g1j4nqll.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "BL" == Benjamin C R LaHaise <blah@kvack.org> writes:

BL> On 23 Apr 1998, Eric W. Biederman wrote:
>> Please excuse me for thinking out loud but private mappings seems to be
>> a hard problem that has not been correctly implemented in the linux
>> kernel.
>> 
>> Definition of Private Mappings:
>> A private mapping is a copy-on-write mapping of a file.  
>> 
>> That is if the file is written to after the mapping is established,
>> the contents of the mapping will always remain what the contents of
>> the file was at the time of the private mapping.

BL> No, this is not the case.  Examine the behaviour of other unicies out
BL> there that implement mmap.  The following is quoted from the man page for
BL> mmap on Solaris:

BL>      MAP_SHARED and MAP_PRIVATE describe the disposition of write
BL>      references  to  the  memory object.  If MAP_SHARED is speci-
BL>      fied, write references will change the  memory  object.   If
BL>      MAP_PRIVATE  is  specified, the initial write reference will
BL>      create a private copy of the memory object page and redirect
BL>      the  mapping  to  the copy. Either MAP_SHARED or MAP_PRIVATE
BL>      must be specified,  but  not  both.   The  mapping  type  is
BL>      retained across a fork(2).

BL> Note: 'the initial write reference will create a private copy' -- not
BL> the act of reading or mapping.

Right.  That is probably the only reasonable way to implement it.

I stated it as I did so what happens if another process writes to the
file is clear.  Another process writing to the file will be the
`initial write reference'.

So logically MAP_PRIVATE gives you a snapshot of the contents of a
file.   Not that it actually takes that snapshot...

Possibly I'm failing to see the difference in the definitions?

Was it the always remains the same bit?  I was thinking of what the
contents of the mapping would be if you don't write to it.

>> Further if another private mapping is established after one
>> private mapping has been established it should have the file contents
>> of the file at the time the mapping is established.  Not at the time
>> any previous private mapping was established.

BL> Linux does behave this way currently.

Only most of the time.

With private mappings at 1k alignment.  I have written a program
on 2.0.32 and verified this.  I don't believe the code has
significantly changed since then.

The problem is update_vm_cache only looks currently for the primary
inode page.  The one at (offset%PAGE_SIZE)==0.  So the other page at
offset%PAGE_SIZE==1k is not updated.

BL> This would be the appropriate thing to do if you'd like see such exotic
BL> behaviour ;-)
I guess everyone seems to like this :)

Eric
