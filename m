Received: from mail.lu.unisi.ch ([195.176.178.40] verified)
  by ti-edu.ch (CommuniGate Pro SMTP 5.1.12)
  with ESMTP id 22469438 for linux-mm@kvack.org; Tue, 09 Oct 2007 23:10:42 +0200
Message-ID: <470BB2B3.2070800@lu.unisi.ch>
Date: Tue, 09 Oct 2007 18:56:19 +0200
From: Paolo Bonzini <paolo.bonzini@lu.unisi.ch>
Reply-To: bonzini@gnu.org
MIME-Version: 1.0
Subject: Re: [Bug 9138] New: kernel overwrites MAP_PRIVATE mmap
References: <bug-9138-27@http.bugzilla.kernel.org/> <20071009083913.212fb3e3.akpm@linux-foundation.org> <470BA58F.8050907@lu.unisi.ch>
In-Reply-To: <470BA58F.8050907@lu.unisi.ch>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bonzini@gnu.org
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This testcase is not a regression, but it is still a bug, and I believe
the root cause is the same: in this case, it is ftruncate modifying the
length of MAP_PRIVATE mmaps.


#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>

int main()
{
   system ("echo foo > gst.im");
   int f = open ("gst.im", O_RDONLY);

   char *p = mmap(NULL, 1628636, PROT_READ, MAP_PRIVATE, f, 0);
   close (f);
   f = open("gst.im", O_RDWR|O_CREAT, 0666);
   printf ("%s", p);
   ftruncate (f, 0);
   mmap(NULL, 401408, PROT_READ|PROT_WRITE|PROT_EXEC,
        MAP_PRIVATE|MAP_ANON, -1, 0);
   printf ("%s", p);
}


Expected (and this is what it gives on e.g. Darwin):

foo
foo

Actual output:

foo
Bus error


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
