Message-ID: <XFMail.20010624150303.mhw6@cornell.edu>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="_=XFMail.1.5.0.Linux:20010624150303:6994=_"
Date: Sun, 24 Jun 2001 15:03:03 -0400 (EDT)
From: Koni <mhw6@cornell.edu>
Subject: memory problems:  mlockall() w/ pthreads on 2.4
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: wireless@ithacaweb.com
List-ID: <linux-mm.kvack.org>

This message is in MIME format
--_=XFMail.1.5.0.Linux:20010624150303:6994=_
Content-Type: text/plain; charset=us-ascii


Hi Folks,

My name is Koni. I have just joined the Linux-MM mailing list. 

I am looking into a curious little problem involving mlockall() in threaded
programs, running on Linux 2.4 kernels.

The program (http://slan.sourceforge.net) uses mlockall() to keep cryptographic
keys and state information away from the disk.

Under 2.2 kernels, the client program uses about 700Kb of memory. The server
would use just over a meg, plus a little more for each active session. UNder
2.4 however, the client may take several megabytes, and the server, with no
active connections, takes 11 megs just to start up.

After a whole day of head scratching, I tracked this down to the combination of
using mlockall() and pthread_create(). Any combination bleeds a little over 2M
(as reported by top or ps) per thread created. It is not shown in a profiling
tool such as memprof.

Attached is a program which will demonstrate the problem. It takes two
arguments on the commandline: the first is how many threads to create, the
second is the amount of memory to allocate in each thread explicitly. 0 for the
second argument prevents calls to malloc. 0 for the first argument prevents
threads from being started. Not running it as root stops the mlockall() from
suceeding but the program will run anyway. It runs forever (sleeping) until it
is stopped by ctrl-c or whatever, so that the core size can be observed.

I've played with various ordering of mlockall() and pthread_create() as well as
thread attributes, such as not using the PTHREAD_CREATE_DETACHED attribute.
That is a real kicker -- in that case, I saw 8 megs bleed per call to
pthread_create()! It doesn't matter when mlockall() or pthread_create() is
called. Calling mlockall(MCL_CURRENT|MCL_FUTURE) after pthread_create() still
results in significant memory bleed per running thread.

However, calling after pthread_create() with just mlockall(MCL_FUTURE), does
NOT bleed memory. calling with mlockall(MCL_CURRENT) does. 

My interpretation of that: mlockall(MCL_CURRENT) is locking the entire
possible stack space of every running thread (and if MCL_FUTURE is also given,
then the entire stack of every new thread created as well).

Questions on that:

This action could be argued as correct, except: why is a single (no
pthread_create()s) thread process not have a locked 8 meg stack? How does the
kernel know to lock only the in use portion of the stack? Or rather, does it
lock the main stack of  a process, and only the used pages? Is this likely to
be a pthread library problem: like pthreads (or maybe clone() -- I don't know
how it works exactly) allocating some (large) chunk of memory to be used as the
stack for each thread it starts? If that is the case, why is mlockall() needed
to observe this? 

Any ideas? I'll have to be a bit more clever I guess to keep the memory size
down for the SLAN programs running on 2.4, while still having pages locked. It
was certainly nice (from the development point of view) to just call mlockall()
at program startup and then forget about it. Trying to pick and choose which
pages to lock looks very difficult since the public key stuff is all done with
gmp and I haven't control over how those functions allocate (stack vs. heap)
memory and pass parameters to internal functions.


Cheers,
Koni

-- 
mhw6@cornell.edu
Koni (Mark Wright)
Solanaceae Genome Network	250 Emerson Hall - Cornell University
Strategic Forecasting		242 Langmuir Laboratory
Lightlink Internet		http://www.lightlink.com/

"If I'm right 90% of the time, why quibble about the other 3%?"

--_=XFMail.1.5.0.Linux:20010624150303:6994=_
Content-Disposition: attachment; filename="suckup_memory.c"
Content-Transfer-Encoding: base64
Content-Description: suckup_memory.c
Content-Type: application/octet-stream; name=suckup_memory.c; SizeOnDisk=1880

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KCiNpbmNsdWRlIDxzdHJpbmcu
aD4KI2luY2x1ZGUgPGVycm5vLmg+CgojaW5jbHVkZSA8dW5pc3RkLmg+CgojaW5jbHVkZSA8cHRo
cmVhZC5oPgojaW5jbHVkZSA8c3lzL21tYW4uaD4KCiNkZWZpbmUgTUFYX1RIUkVBRFMgKDI1NikK
I2RlZmluZSBNQVhfQkxFRUQgICAoMTAyNCoxMDI0KjIwKQoKc3RhdGljIHZvaWQgdXNhZ2UoY2hh
ciAqYXJndltdLCBpbnQgZXhpdF9jb2RlKSB7CgogIGZwcmludGYoc3RkZXJyLCJcblxuJXM6IHVz
YWdlXG4iLGFyZ3ZbMF0pOwogIGZwcmludGYoc3RkZXJyLCIlcyA8bnVtYmVyIG9mIHRocmVhZHM+
IDxieXRlcyBhbGxvY2F0ZWQgcGVyIHRocmVhZD5cblxuIiwKCSAgYXJndlswXSk7IAogIGV4aXQo
ZXhpdF9jb2RlKTsKfQoKc3RhdGljIHZvaWQgKm1lbW9yeV9zdWNrZXIodm9pZCAqYXJnKSB7CiAg
aW50IHN1Y2tfYnl0ZXM7CiAgdm9pZCAqcDsKICAKICBzdWNrX2J5dGVzID0gKigoaW50ICopIGFy
Zyk7CiAgLyogQWxsb2NhdGUgYW5kIHdyaXRlIHRvIGl0IHNvIHRoYXQgaXRzIHJlYWxseSBhbGxv
Y2F0ZWQgKi8KICBwID0gY2FsbG9jKDEsIHN1Y2tfYnl0ZXMpOwogIGlmIChwID09IE5VTEwpIHsK
ICAgIGZwcmludGYoc3RkZXJyLCJVbmFibGUgdG8gYWxsb2NhdGUgbWVtb3J5IGluIHRocmVhZCAj
JWxkICglcylcbiIsCgkgICAgcHRocmVhZF9zZWxmKCksIHN0cmVycm9yKGVycm5vKSk7CiAgfQoK
ICAvKiBTaXQgb24gaXQgKi8KICB3aGlsZSgxKSBzbGVlcCgzNjAwKTsKfQoKaW50IG1haW4oaW50
IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkgewoKICBwdGhyZWFkX3Qgc3Vja190aHJlYWRzW01BWF9USFJF
QURTXTsKICBwdGhyZWFkX2F0dHJfdCB0aHJlYWRfYXR0cmlidXRlczsKICBpbnQgaTsKICBpbnQg
bl90aHJlYWRzLCBibGVlZF9zaXplOwoKICBpZiAoYXJnYyE9MykgdXNhZ2UoYXJndiwgMSk7CiAg
bl90aHJlYWRzID0gYXRvaShhcmd2WzFdKTsKICBibGVlZF9zaXplID0gYXRvaShhcmd2WzJdKTsK
CiAgaWYgKGJsZWVkX3NpemUgPCAwKSB1c2FnZShhcmd2LCAxKTsKICBpZiAobl90aHJlYWRzIDwg
MCkgdXNhZ2UoYXJndiwgMSk7CiAgCiAgaWYgKG5fdGhyZWFkcyA+IE1BWF9USFJFQURTKSB7CiAg
ICBuX3RocmVhZHMgPSBNQVhfVEhSRUFEUzsKICAgIGZwcmludGYoc3RkZXJyLCJOdW1iZXIgb2Yg
dGhyZWFkcyBsaW1pdGVkIHRvICVkXG4iLG5fdGhyZWFkcyk7CiAgfQoKICBpZiAoYmxlZWRfc2l6
ZSA+IE1BWF9CTEVFRCkgewogICAgYmxlZWRfc2l6ZSA9IE1BWF9CTEVFRDsKICAgIGZwcmludGYo
c3RkZXJyLCJCeXRlcyBhbGxvY2F0ZWQgcGVyIHRocmVhZCBsaW1pdGVkIHRvICVkXG4iLGJsZWVk
X3NpemUpOwogIH0KCiAgaWYgKG1sb2NrYWxsKE1DTF9DVVJSRU5UfE1DTF9GVVRVUkUpKSB7CiAg
ICBmcHJpbnRmKHN0ZGVyciwiVW5hYmxlIHRvIGxvY2sgbWVtb3J5IHBhZ2VzIGZvciB0aGlzIHBy
b2Nlc3MgKCVzKVxuIiwKCSAgICBzdHJlcnJvcihlcnJubykpOwogICAgZnByaW50ZihzdGRlcnIs
IlJ1bm5pbmcgYXMgcm9vdD8gKENvbnRpbnVpbmcgd2l0aG91dCBwYWdlcyBsb2NrZWQpXG4iKTsK
ICB9CgogIHB0aHJlYWRfYXR0cl9pbml0KCZ0aHJlYWRfYXR0cmlidXRlcyk7CiAgcHRocmVhZF9h
dHRyX3NldGRldGFjaHN0YXRlKCZ0aHJlYWRfYXR0cmlidXRlcyxQVEhSRUFEX0NSRUFURV9ERVRB
Q0hFRCk7CiAgZm9yKGk9MDtpPG5fdGhyZWFkcztpKyspIHsKICAgIHB0aHJlYWRfY3JlYXRlKHN1
Y2tfdGhyZWFkcyArIGksICZ0aHJlYWRfYXR0cmlidXRlcywgbWVtb3J5X3N1Y2tlciwKCQkgICAm
YmxlZWRfc2l6ZSk7CiAgfQoKICB3aGlsZSgxKSBzbGVlcCg3MjAwKTsKICByZXR1cm4gMDsKfQo=

--_=XFMail.1.5.0.Linux:20010624150303:6994=_--
End of MIME message
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
