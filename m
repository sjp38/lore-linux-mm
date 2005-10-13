Message-ID: <434EA6E8.30603@programming.kicks-ass.net>
Date: Thu, 13 Oct 2005 20:26:48 +0200
From: Peter Zijlstra <peter@programming.kicks-ass.net>
MIME-Version: 1.0
Subject: Another Clock-pro approx
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@redhat.com, sjiang@lanl.gov
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've been thinking on another clock-pro approximation.

Each page has 3 bits: hot/cold, test and referenced.
Say we have 3 lists: T1, T2 and T3.
and variable: s

T1 will have hot and cold pages, T2 will only have cold pages and T3
will have the non-resident pages.
c will be the total number of resident pages; |T1| + |T2| + |T3| = 2c.


T1-rotation:

h/c   test   ref          action
 0       0       0           T2-000
 0       0       1           T2-001
 0       1       0           T2-000
 0       1       1           T1-100
 1       0       0           T2-001
 1       0       1           T1-100
 1       1       0           <cannot happen>
 1       1       1           <cannot happen>


T2-rotation:

h/c   test   ref          action
 0       0       0           <remove page from list>
 0       0       1           T1-000
 0       1       0           T3-010
 0       1       1           T1-100


T3-rotation: frees up non-resident slots

So, on fault we rotate T2, unless empty then we start by rotating T1
until T2 contains at least 1 cold page.
If a T2 rotation creates a hot page, we rotate T1 to degrade a hot
page to a cold page in order to keep the cold page target m_c.
Every T1 rotation adds |T1| to s. While s > c, we subtract c from s and
turn T3 for each subtraction.

Compare to clock-pro:
  T1-rotation <-> Hand_hot
  T2-rotation <-> Hand_cold
  T3-rotation <-> Hand_test

The normal m_c adaption rules can be applied.

Zoned edition:
This can be done per zone by having:
T1_i, T2_i, T3_j, s, t, u_j
where _i is the zone index and _j the non-resident bucket index.

Then each T1_i turn will add |T1_i| to s, each c in s will increment t by 1.
On each non-resident bucket access we increment u_j until it equals t
and for each increment we rotate the bucket.



Kind regards,

Peter Zijlstra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
